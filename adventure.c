#include "adventure.h"

#define ACTION_TIME 0.5

BITMAP *buffer;
BITMAP *room_art = NULL, *room_hot = NULL;
BITMAP *actionbar, *inventory;
HOTSPOT *hotspots[256];

int last_mouse;
int last_key[KEY_MAX];
STATE game_state = STATE_GAME;
float life = 0;

struct {
	int x, y, relevant, result;
	const char *type, *object;
	float started;
	STATE last_state;
} action_state;

struct {
	int active;
	const char *name;
	BITMAP *image;
} active_item;


int hotspot(int x, int y) {
	return (getpixel(room_hot, x, y) & (255 << 16)) >> 16;
}

int in_rect(int x, int y, int x1, int y1, int x2, int y2) {
	return x >= x1 && x < x2 && y >= y1 && y < y2;
}

OBJTYPE get_object_at_cursor() {
	const char *name = NULL;
	
	if (game_state & STATE_INVENTORY && in_rect(mouse_x, mouse_y, 270, 210, 270 + 741, 210 + 300)) {
		int i = 1;
		lua_getglobal(script, "player");
		lua_pushstring(script, "inventory");
		lua_gettable(script, -2);
		int t = lua_gettop(script);

		lua_pushnil(script);
		while (lua_next(script, t) != 0) {
			if (lua_isnil(script, -1)) {
				lua_pop(script, 1);
				continue;
			}
			if (in_rect(mouse_x, mouse_y, 270 + 75 * (i % 10), 215 + 75 * (i / 10), 270 + 75 * (i % 10) + 64, 215 + 75 * (i / 10) + 64)) {
				name = lua_tostring(script, -2);
			}
			lua_pop(script, 1);
			i++;
		} lua_pop(script, 2);
		
		if (name) {
			lua_getglobal(script, "items");
			lua_pushstring(script, name);
			lua_gettable(script, -2);
			return OBJ_ITEM;
		}
	} else {
		HOTSPOT *hs = hotspots[hotspot(mouse_x, mouse_y)];
		if (hs != NULL) {
			lua_newtable(script);
			lua_pushstring(script, "internal_name");
			lua_pushstring(script, hs->internal_name);
			lua_settable(script, -2);
			lua_pushstring(script, "display_name");
			lua_pushstring(script, hs->display_name);
			lua_settable(script, -2);
			return OBJ_HOTSPOT;
		}
	}
}

void update_game() {
	lua_getglobal(script, "tick");
	lua_call(script, 0, 0);
	
	if (action_state.result) { // we just returned from action
		HOTSPOT *hs = hotspots[hotspot(action_state.x, action_state.y)];
		
		lua_getglobal(script, "do_callback");
		lua_pushstring(script, action_state.type);
		lua_pushstring(script, action_state.object);
		switch (action_state.result) {
			case 1: lua_pushstring(script, "look"); break;
			case 2: lua_pushstring(script, "talk"); break;
			case 3: lua_pushstring(script, "touch"); break;
		}

		lua_call(script, 3, 0);
		
		action_state.result = 0;
	}
	
	if (mouse_b & 1 && !(last_mouse & 1)) { // we have a click
		HOTSPOT *hs = hotspots[hotspot(mouse_x, mouse_y)];
		if (hs != NULL) { // on a hotspot
			if (active_item.active) {
				lua_getglobal(script, "do_callback");
				lua_pushstring(script, "hotspot");
				lua_pushstring(script, hs->internal_name);
				lua_pushstring(script, active_item.name);
				lua_call(script, 3, 0);
				
				active_item.active = 0;
			} else {
				action_state.started = life;
				action_state.x = mouse_x;
				action_state.y = mouse_y;
				action_state.type = "hotspot";
				action_state.object = hs->internal_name;
				action_state.relevant = 1;
			}
		} else {
			action_state.relevant = 0;
			
			if (is_walkable(mouse_x, mouse_y)) { // on walkable ground
				lua_getglobal(script, "player");
				POINT *player = actor_position();
				
				if (is_pathable(player->x, player->y, mouse_x, mouse_y)) {
					lua_getglobal(script, "player");
					lua_pushstring(script, "goal");
					LUA_PUSHPOS(mouse_x, mouse_y);				
					lua_settable(script, -3);
				} else {
					int dest = closest_waypoint(mouse_x, mouse_y);
					int here = closest_waypoint(player->x, player->y);

					lua_getglobal(script, "walk");
					lua_getglobal(script, "player");
					LUA_PUSHPOS(mouse_x, mouse_y);
					lua_call(script, 2, 0);
				}
				
				free(player);
			}
		}
	} else if (mouse_b & 1 && action_state.relevant) { // time to bring up the action menu
		if (life > action_state.started + ACTION_TIME) {
			game_state = STATE_ACTION;
			action_state.last_state = STATE_GAME;
		}
	} else if (mouse_b & 2 && !(last_mouse & 2)) {
		game_state = STATE_INVENTORY;
	}
}

void update_action() {
	if (!(mouse_b & 1)) {
		game_state = action_state.last_state;
		
		action_state.result = 0;
		if (in_rect(mouse_x, mouse_y, action_state.x - 72, action_state.y - 24, action_state.x - 24, action_state.y + 24))
			action_state.result = 2;
		else if (in_rect(mouse_x, mouse_y, action_state.x - 24, action_state.y - 24, action_state.x + 24, action_state.y + 24))
			action_state.result = 1;
		else if (in_rect(mouse_x, mouse_y, action_state.x + 24, action_state.y - 24, action_state.x + 72, action_state.y + 24))
			action_state.result = 3;
	}
}

void update_inventory() {
	if (mouse_b & 2 && !(last_mouse & 2))
		game_state = STATE_GAME;
	else if (mouse_b & 1 && !(last_mouse & 1)) { // we have a click
		int i = 0;
		lua_getglobal(script, "player");
		lua_pushstring(script, "inventory");
		lua_gettable(script, -2);
		int t = lua_gettop(script);

		lua_pushnil(script);
		while (lua_next(script, t) != 0) {
			if (lua_isnil(script, -1)) {
				lua_pop(script, 1);
				continue;
			}
			if (in_rect(mouse_x, mouse_y, 270 + 75 * (i % 10), 215 + 75 * (i / 10), 270 + 75 * (i % 10) + 64, 215 + 75 * (i / 10) + 64)) {
				action_state.started = life;
				action_state.x = mouse_x;
				action_state.y = mouse_y;
				action_state.type = "item";
				action_state.object = lua_tostring(script, -2);
				action_state.relevant = 1;
			}
			lua_pop(script, 1);
			i++;
		} lua_pop(script, 2);
	} else if (!(mouse_b & 1) && last_mouse & 1) { // we have a click on an item
		int i = 0;
		lua_getglobal(script, "player");
		lua_pushstring(script, "inventory");
		lua_gettable(script, -2);
		int t = lua_gettop(script);

		lua_pushnil(script);
		while (lua_next(script, t) != 0) {
			if (lua_isnil(script, -1)) {
				lua_pop(script, 1);
				continue;
			}
			if (in_rect(mouse_x, mouse_y, 270 + 75 * (i % 10), 215 + 75 * (i / 10), 270 + 75 * (i % 10) + 64, 215 + 75 * (i / 10) + 64)) {
				if (active_item.active) {
					lua_getglobal(script, "do_callback");
					lua_pushstring(script, "item");
					lua_pushstring(script, lua_tostring(script, -4));
					lua_pushstring(script, active_item.name);
					lua_call(script, 3, 0);
					active_item.active = 0;
					game_state = STATE_GAME;
				} else {
					active_item.active = 1;
					active_item.name = lua_tostring(script, -2);
					
					lua_pushstring(script, "image");
					lua_gettable(script, -2);
					
					active_item.image = (BITMAP*)lua_touserdata(script, -1);
					action_state.relevant = 0;
					
					lua_pop(script, 1);
				}
			}
			lua_pop(script, 1);
			i++;
		} lua_pop(script, 2);
		
		
	} else if (mouse_b & 1 && action_state.relevant) { // time to bring up the action menu
		if (life > action_state.started + ACTION_TIME) {
			game_state = STATE_ACTION | STATE_INVENTORY;
			action_state.last_state = STATE_GAME;
			action_state.relevant = 0;
		}
	} else if (!(mouse_b & 1) && action_state.relevant) { // select item
		action_state.relevant = 0;
		game_state = STATE_GAME;
	}
}

int get_dialogue_count() {
	lua_getglobal(script, "table");
	lua_pushstring(script, "getn");
	lua_gettable(script, -2);
	lua_getglobal(script, "conversation");
	lua_pushstring(script, "options");
	lua_gettable(script, -2);
	lua_remove(script, -2);
	lua_call(script, 1, 1);
	
	int ret = lua_tonumber(script, -1);
	lua_pop(script, 2);
	return ret;
}

void update_dialogue() {
	int dialogue = get_dialogue_count();
	
	if (mouse_b & 1 && !(last_mouse & 1)) {
		for (int i = 0; i < dialogue; i++) {
			int y =  695 - 14 * dialogue + 14 * i;
			if (in_rect(mouse_x, mouse_y, 0, y, 1280, y + 14)) {
				
				lua_getglobal(script, "conversation");
				lua_pushstring(script, "continue");
				lua_gettable(script, -2);
				lua_pushnumber(script, i + 1);
				lua_call(script, 1, 0);
				lua_pop(script, 1);
			}
		}
	}
}

void update() {
	life += 1 / (float)FRAMERATE;
	
	if (key[KEY_ESC]) exit(0);
	
	int dialogue = get_dialogue_count();
	if (game_state & STATE_GAME && !dialogue) update_game();
	else if (dialogue) {
		update_dialogue();
	}
	else {
		if (game_state & STATE_ACTION) update_action();
		if (game_state & STATE_INVENTORY) update_inventory();
	}
	
	last_mouse = mouse_b;
	
	for (int i = 0; i < KEY_MAX; i++)
		last_key[i] = key[i];
}

void frame() {
	char cbuffer[10];
	
	update();

	acquire_bitmap(buffer);
	clear_to_color(buffer, 0);
	blit(room_art, buffer, 0, 0, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
	
	lua_getglobal(script, "actors");
	int t = lua_gettop(script);

	lua_pushnil(script);
	while (lua_next(script, t) != 0) {
		POINT *pos = actor_position(lua_tostring(script, -2));
		
		lua_pushstring(script, "flipped");
		lua_gettable(script, -2);
		int flipped = lua_tonumber(script, -1);
		lua_pop(script, 1);
		
		lua_pushstring(script, "aplay");
		lua_gettable(script, -2);
		lua_pushstring(script, "set");
		lua_gettable(script, -2);
		lua_pushstring(script, "image");
		lua_gettable(script, -2);
		BITMAP *sheet = (BITMAP*)lua_touserdata(script, -1);
		lua_pop(script, 1);
		
		lua_pushstring(script, "xorigin");
		lua_gettable(script, -2);
		int xorigin = lua_tonumber(script, -1);
		lua_pop(script, 1);
		
		lua_pushstring(script, "yorigin");
		lua_gettable(script, -2);
		int yorigin = lua_tonumber(script, -1);
		lua_pop(script, 1);
		
		lua_pushstring(script, "width");
		lua_gettable(script, -2);
		int width = lua_tonumber(script, -1);
		lua_pop(script, 1);
		
		lua_pushstring(script, "height");
		lua_gettable(script, -2);
		int height = lua_tonumber(script, -1);
		lua_pop(script, 2);

		lua_pushstring(script, "frame");
		lua_gettable(script, -2);
		int frame = lua_tonumber(script, -1);
		lua_pop(script, 1);

		lua_pushstring(script, "set");
		lua_gettable(script, -2);
		
		lua_getglobal(script, "animation");
		lua_pushstring(script, "get_frame");
		lua_gettable(script, -2);
		lua_pushvalue(script, -3);
		lua_pushnumber(script, frame);
		lua_call(script, 2, 2);
		
		int xsrc = lua_tonumber(script, -2);
		int ysrc = lua_tonumber(script, -1);
		
		lua_pop(script, 5);
	
		
		BITMAP *tmp = create_bitmap(width, height);
		blit(sheet, tmp, xsrc, ysrc + 1, 0, 0, width, height);
		draw_sprite_ex(buffer, tmp, pos->x - xorigin, pos->y - yorigin, DRAW_SPRITE_NORMAL, flipped);
		destroy_bitmap(tmp);
		
		free(pos);
		lua_pop(script, 1);
	} lua_pop(script, 1);
	
	HOTSPOT *hs = hotspots[hotspot(mouse_x, mouse_y)];
	if (hs != NULL)
		textout_ex(buffer, font, hs->display_name, 10, 10, 0, -1);
	
	if (game_state & STATE_INVENTORY) {
		masked_blit(inventory, buffer, 0, 0, 270, 210, 741, 300); 
		
		int i = 0;
		lua_getglobal(script, "player");
		lua_pushstring(script, "inventory");
		lua_gettable(script, -2);
		int t = lua_gettop(script);

		lua_pushnil(script);
		while (lua_next(script, t) != 0) {
			if (lua_isnil(script, -1)) {
				lua_pop(script, 1);
				continue;
			}
			
			lua_pushstring(script, "image");
			lua_gettable(script, -2);
			
			masked_blit((BITMAP*)lua_touserdata(script, -1), buffer, 0, 0, 270 + 75 * (i % 10), 215 + 75 * (i / 10), 64, 64); 
			lua_pop(script, 2);
			i++;
		} lua_pop(script, 2);
	}
	
	if (game_state & STATE_ACTION)
		masked_blit(actionbar, buffer, 0, 0, action_state.x - 72, action_state.y - 24, 144, 48); 
	
	int dialogue = get_dialogue_count();
	if (dialogue) {
		int i = 0;
		lua_getglobal(script, "conversation");
		lua_pushstring(script, "options");
		lua_gettable(script, -2);
		int t = lua_gettop(script);

		lua_pushnil(script);
		while (lua_next(script, t) != 0) {
			int y =  695 - 14 * dialogue + 14 * i ;
			if (in_rect(mouse_x, mouse_y, 0, y, 1280, y + 14))
				textout_ex(buffer, font, lua_tostring(script, -1), 25, y, makecol(255, 0, 0), -1);
			else
				textout_ex(buffer, font, lua_tostring(script, -1), 25, y, 0, -1);
			lua_pop(script, 1);
			i++;
		} lua_pop(script, 2);
	}
	
	masked_blit(mouse_sprite, buffer, 0, 0, mouse_x, mouse_y, 16, 16);
	if (active_item.active)
		masked_blit(active_item.image, buffer, 0, 0, mouse_x, mouse_y, 64, 64);
	
	release_bitmap(buffer);
    blit(buffer, screen, 0, 0, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

int main(int argc, char* argv[]) {
	allegro_init();
	install_keyboard();
	install_mouse();
	install_timer();
	
	set_color_depth(32);
	set_gfx_mode(GFX_AUTODETECT_WINDOWED, SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0);

	buffer = create_bitmap(SCREEN_WIDTH, SCREEN_HEIGHT);
	actionbar = load_bitmap("resources/actionbar.pcx", NULL);
	inventory = load_bitmap("resources/inventory.pcx", NULL);
	action_state.relevant = 0;
	active_item.active = 0;
	
	init_script();
	install_int(&frame, 1000 / FRAMERATE);
	
	scanf("%d", &argc); 
	return 0;
}
END_OF_MAIN();
