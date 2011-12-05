#include "adventure.h"

#define ACTION_TIME 0.5

BITMAP *buffer, *actionbar, *inventory;
BITMAP *room_art = NULL, *room_hot = NULL;

HOTSPOT *hotspots[256];
const char *object_name = NULL;
float life = 0;

STATE game_state = STATE_GAME;

int cursor = 0;

int last_mouse, last_key[KEY_MAX];
int quit = 0;
int fps = 0;
int in_console = 0;
int door_travel = 0;

volatile int ticks = 0;
sem_t semaphore_rest;

struct {
    int x, y, relevant, result;
    const char *type, *object;
    float started;
    STATE last_state;
    POINT* walkspot;
    int owns_walkspot;
} action_state;

struct {
    int active;
    const char *name;
    BITMAP *image;
} active_item;

// is (x1, y1) < (x, y) < (x2, y2)?
int in_rect(int x, int y, int x1, int y1, int x2, int y2) {
    return x >= x1 && x < x2 && y >= y1 && y < y2;
}

// did we just click a button?
int is_click(int button) {
    return mouse_b & button && !(last_mouse & button);
}

// calculates pixel perfect detection
//TODO(sandy): i think this fails for animated sprites
int is_pixel_perfect(BITMAP *sheet, int x, int y, int width, int height, int xorigin, int yorigin, int flipped) {
    int direction = flipped ? -1 : 1;

    int relx = x - xorigin;

    if (flipped)
        xorigin += width;

    return getpixel(sheet, xorigin + relx * direction, y + yorigin) != ((255 << 16) | 255);
}

// sets the object of the action bar
void set_action(const char *type, const char *obj) {
    action_state.started = life;
    action_state.x = mouse_x;
    action_state.y = mouse_y;
    action_state.type = type;
    action_state.object = obj;
    action_state.relevant = 1;
}

// fires a game event
void fire_event(const char *type, const char *obj, const char *method) {
    lua_getglobal(script, "do_callback");
    lua_pushstring(script, type);
    lua_pushstring(script, obj);
    lua_pushstring(script, method);
    lua_call(script, 3, 0);
}

// performs a room exit
void do_exit(EXIT *exit) {
// TODO(sandy): do something about exits
    lua_getglobal(script, "rooms");
    lua_pushstring(script, exit->room);
    lua_gettable(script, -2);
    lua_pushstring(script, "switch");
    lua_gettable(script, -2);
    lua_call(script, 0, 0);
    lua_pop(script, 2);
}

// updates the regular game state
void update_game() {
    update_mouse();
    
    // update lua's game loop
    lua_getglobal(script, "events");
    lua_pushstring(script, "game");
    lua_gettable(script, -2);
    lua_pushstring(script, "tick");
    lua_gettable(script, -2);
    
    lua_pushstring(script, "game");
    lua_call(script, 1, 0);
    lua_pop(script, 2);
    
    return;
}

// see update_game(). it is very parallel
void update_inventory() {
    lua_getregister(script, "render_inv");
    int t = lua_gettop(script);

    int found = 0;
    cursor = 0;

    lua_pushnil(script);
    while (lua_next(script, t) != 0) {
        lua_pushstring(script, "name");
        lua_gettable(script, -2);
        const char *name = lua_tostring(script, -1);
        lua_pop(script, 1);

        lua_pushstring(script, "x");
        lua_gettable(script, -2);
        int x = lua_tonumber(script, -1);
        lua_pop(script, 1);

        lua_pushstring(script, "y");
        lua_gettable(script, -2);
        int y = lua_tonumber(script, -1);
        lua_pop(script, 1);

        lua_pushstring(script, "width");
        lua_gettable(script, -2);
        int width = lua_tonumber(script, -1);
        lua_pop(script, 1);

        lua_pushstring(script, "height");
        lua_gettable(script, -2);
        int height = lua_tonumber(script, -1);
        lua_pop(script, 1);

        if (in_rect(mouse_x, mouse_y, x, y, x + width, y + height)) {
            object_name = name;
            found = 1;
            cursor = 5;

            if (is_click(1))
                if (active_item.active) {
                    fire_event("combine", lua_tostring(script, -2), active_item.name);
                    active_item.active = 0;
                } else
                    set_action("item", lua_tostring(script, -2));
            else if (!(mouse_b & 1) && last_mouse & 1) {
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
    } lua_pop(script, 1);

    if (mouse_b & 1 && action_state.relevant) { // time to bring up the action menu
        if (life > action_state.started + ACTION_TIME) {
            game_state = STATE_ACTION | STATE_INVENTORY;
            action_state.last_state = STATE_GAME;
        }
    } else if (is_click(2)) {
        action_state.relevant = 0;
        if (active_item.active)
            active_item.active = 0;
        else
            game_state = STATE_GAME;
    } else if (is_click(1) && !in_rect(mouse_x, mouse_y, 270, 210, 270 + 741, 510)) {
        game_state = STATE_GAME;
    }
}

// returns the number of dialogue options available
// if 0, we are not in a conversation
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

// we are in the dialogue gamestate
void update_dialogue() {
    lua_getglobal(script, "tick");
    lua_pushstring(script, "dialogue");
    lua_call(script, 1, 0);

    int dialogue = get_dialogue_count();

    // we have a click
    if (is_click(1)) {
        // but where??
        for (int i = 0; i < dialogue; i++) {
            int y =  695 - 14 * dialogue + 14 * i;

            if (in_rect(mouse_x, mouse_y, 0, y, 1280, y + 14)) {
                // this is it!
                
                lua_getglobal(script, "conversation");
                lua_pushstring(script, "continue");
                lua_gettable(script, -2);
                lua_pushnumber(script, i + 1);
                lua_call(script, 1, 0);
                lua_pop(script, 1);
            }
        }
    }

    action_state.relevant = 0;
}

// generic update - dispatches on gamestate
void update() {
    life += 1 / (float)FRAMERATE;

    if (key[KEY_ESC] && !last_key[KEY_ESC]) quit = 1;
    if (key[KEY_F10]) open_console();

    int dialogue = get_dialogue_count();
    
    //if (game_state & STATE_GAME && !dialogue) 
        update_game();
    //else if (dialogue) {
        //update_dialogue();
    //} else {
        //if (game_state & STATE_ACTION) 
            //update_action();
        //else if (game_state & STATE_INVENTORY)
            //update_inventory();
    //}

    last_mouse = mouse_b;

    for (int i = 0; i < KEY_MAX; i++)
        last_key[i] = key[i];
}

// draws the foreground of a hot image
void draw_foreground(int level) {
    int col;
    for (int y = 0; y < SCREEN_HEIGHT; y++)
    for (int x = 0; x < SCREEN_WIDTH; x++)
        if ((getpixel(room_hot, x, y) & 255) == level)
            putpixel(buffer, x, y, getpixel(room_art, x, y));
}

// draws the game
void frame() {
    char cbuffer[10];

    acquire_bitmap(buffer);

    lua_getglobal(script, "engine");
    lua_pushstring(script, "events");
    lua_gettable(script, -2);
    
    lua_pushstring(script, "draw");
    lua_gettable(script, -2);
    
    lua_call(script, 0, 0);
    lua_pop(script, 2);
    
    release_bitmap(buffer);
    blit(buffer, screen, 0, 0, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

// interrupt for the sempahore ticker
void ticker() {
    if (!in_console) {
        sem_post(&semaphore_rest);
        ticks++;
    }
}
END_OF_FUNCTION(ticker);

int main(int argc, char* argv[]) {
    sem_init(&semaphore_rest, 0, 1);

    allegro_init();
    install_keyboard();
    install_mouse();
    install_timer();

    LOCK_VARIABLE(ticks);
    LOCK_FUNCTION(ticker);

    set_color_depth(32);
    set_gfx_mode(GFX_AUTODETECT_WINDOWED, SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0);

    // load resources
    buffer = create_bitmap(SCREEN_WIDTH, SCREEN_HEIGHT);
    
    // set state
    action_state.relevant = 0;
    action_state.walkspot = NULL;
    active_item.active = 0;
    enabled_paths[255] = 1;

    // set script state
    init_script();
    lua_setconstant(script, "screen_width", number, SCREEN_WIDTH);
    lua_setconstant(script, "screen_height", number, SCREEN_HEIGHT);
    lua_setconstant(script, "framerate", number, 60);
    
    luaL_dofile(script, "game/boot.lua");
    
    init_console(32);
    install_int_ex(&ticker, BPS_TO_TIMER(FRAMERATE));

    int frames_done = 0;
    float old_time = 0;

    while (!quit) {
        sem_wait(&semaphore_rest);

        if (life - old_time >= 1) {
            fps = frames_done;
            frames_done = 0;
            old_time = life;
            
            lua_getglobal(script, "engine");
            lua_pushstring(script, "fps");
            lua_pushnumber(script, fps);
            lua_settable(script, -3);
            lua_pop(script, 1);
        }

        while (ticks > 0) {
            int old_ticks = ticks;
            update();
            ticks--;

            if (old_ticks <= ticks) break;
        }

        frame();
        frames_done++;
    }

    remove_int(ticker);
    sem_destroy(&semaphore_rest);

    return 0;
}
END_OF_MAIN();
