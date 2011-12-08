#include "adventure.h"

lua_State *script;

char *strdup2(const char *str) {
    int n = strlen(str) + 1;
    char *dup = malloc(n);
    if (dup)
        strcpy(dup, str);
    return dup;
}

int script_register_hotspot(lua_State *L) {
    HOTSPOT *hotspot;
    
    if (lua_gettop(L) != 3 || !lua_isnumber(L, 1) || !lua_isstring(L, 2)|| !lua_isstring(L, 3)  || lua_tonumber(L, 1) != (int)lua_tonumber(L, 1)) {
        lua_pushstring(L, "register_hotspot expects (int, string, string)");
        lua_error(L);
    }
    
    hotspot = malloc(sizeof(HOTSPOT));
    hotspot->internal_name = strdup2(lua_tostring(L, 2));
    hotspot->display_name = strdup2(lua_tostring(L, 3));
    hotspot->cursor = 5;
    hotspot->exit = NULL;
    
    hotspots[(int)lua_tonumber(L, 1)] = hotspot;
    
    return 0;
}

int script_register_door(lua_State *L) {
    HOTSPOT *hotspot;
    int i;
    
    if (lua_gettop(L) != 4 || !lua_isstring(L, 1) || !lua_isstring(L, 2)|| !lua_isnumber(L, 3)  || !lua_isnumber(L, 4)) {
        lua_pushstring(L, "register_door expects (string, string, int, int)");
        lua_error(L);
    }
    
    hotspot = NULL;
    for (i = 0; i < 256; i++)
        if (hotspots[i] && strcmp(hotspots[i]->internal_name, lua_tostring(L, 1)) == 0) {
            hotspot = hotspots[i];
            break;
        }
        
    if (!hotspot) {
        lua_pushstring(L, "Could not find a registered hotspot to transform into a door. Are you missing a call to register_hotspot?");
        lua_error(L);
    }
    
    hotspot->cursor = lua_tonumber(L, 4);
    hotspot->exit = malloc(sizeof(EXIT));
    hotspot->exit->room = strdup2(lua_tostring(L, 2));
    hotspot->exit->door = lua_tonumber(L, 3);
    
    return 0;
}

int script_load_room(lua_State *L) {
    int i;
    
    if (lua_gettop(L) != 2 || !lua_isuserdata(L, 1) || !lua_isuserdata(L, 2)) {
        lua_pushstring(L, "__load_room expects (BITMAP*, BITMAP*)");
        lua_error(L);
    }

    room_art = *(BITMAP**)lua_touserdata(L, 1);
    room_hot = *(BITMAP**)lua_touserdata(L, 2);
    
    for (i = 0; i < 256; i++)
        if (hotspots[i] != NULL) {
            if (hotspots[i]->exit)
                free(hotspots[i]->exit);
            
            free(hotspots[i]);
            hotspots[i] = NULL;
        }

    build_walkspots();        
    build_waypoints();
    
    lua_setconstant(L, "room_width", number, room_art->w);
    lua_setconstant(L, "room_height", number, room_art->h);
        
    return 0;
}

int script_panic(lua_State *L) {
    lua_Debug debug;
    lua_getstack(L, 1, &debug);
    lua_getinfo(L, "nS", &debug);
    
    printf("LUA ERROR: %s\nat %s\n", lua_tostring(L, 1), debug.name);

	return 0;
}

int script_which_hotspot(lua_State *L) {
    int x, y;
    
    if (lua_gettop(L) != 1 || !lua_istable(L, 1)) {
        lua_pushstring(L, "which_hotspot expects (vec)");
        lua_error(L);
    }
    
    lua_pushstring(L, "x");
    lua_gettable(L, -2);
    x = lua_tonumber(L, -1);
    lua_pop(L, 1);
    
    lua_pushstring(L, "y");
    lua_gettable(L, -2);
    y = lua_tonumber(L, -1);
    
    lua_pushnumber(L, (getpixel(room_hot, x, y) & (255 << 16)) >> 16);
    return 1;
}

void update_mouse() {
    lua_getglobal(script, "engine");
    lua_pushstring(script, "mouse");
    lua_gettable(script, -2);
    
    lua_pushstring(script, "pos");
    lua_gettable(script, -2);
    lua_pushstring(script, "x");
    lua_pushnumber(script, mouse_x);
    lua_settable(script, -3);
    lua_pushstring(script, "y");
    lua_pushnumber(script, mouse_y);
    lua_settable(script, -3);
    lua_pop(script, 1);
    
    lua_pushstring(script, "buttons");
    lua_gettable(script, -2);
    lua_pushstring(script, "left");
    lua_pushboolean(script, mouse_b & 1);
    lua_settable(script, -3);
    lua_pushstring(script, "right");
    lua_pushboolean(script, mouse_b & 2);
    lua_settable(script, -3);
    lua_pushstring(script, "middle");
    lua_pushboolean(script, mouse_b & 4);
    lua_settable(script, -3);
    lua_pop(script, 3);
}

void init_script() {
    script = lua_open();
    luaL_openlibs(script);
    lua_atpanic(script, script_panic);
    
    lua_newtable(script);
    lua_setregister(script, "render_obj");
    lua_newtable(script);
    lua_setregister(script, "render_inv");
    
    lua_register(script, "set_room_data", &script_load_room);
    lua_register(script, "register_hotspot", &script_register_hotspot);
    lua_register(script, "register_door", &script_register_door);
    
    lua_register(script, "which_hotspot", &script_which_hotspot);
    
    register_path();
    register_drawing();
    
    if (luaL_dofile(script, "scripts/init.lua") != 0) {
		printf("%s\n", lua_tostring(script, -1));
	}
}