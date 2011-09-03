#include "adventure.h"

lua_State *script;

POINT *actor_position() {
    lua_pushvalue(script, -1);
    lua_pushstring(script, "pos");
    lua_gettable(script, -2);
    lua_pushstring(script, "x");
    lua_gettable(script, -2);
    int x = (int)lua_tonumber(script, -1);
    lua_pop(script, 1);
    lua_pushstring(script, "y");
    lua_gettable(script, -2);
    int y = (int)lua_tonumber(script, -1);
    lua_pop(script, 3);
    
    POINT *retval = malloc(sizeof(POINT));
    retval->x = x;
    retval->y = y;

    return retval;
}

char *strdup(const char *str) {
    int n = strlen(str) + 1;
    char *dup = malloc(n);
    if (dup)
        strcpy(dup, str);
    return dup;
}

int register_hotspot(lua_State *L) {
    if (lua_gettop(L) != 3 || !lua_isnumber(L, 1) || !lua_isstring(L, 2)|| !lua_isstring(L, 3)  || lua_tonumber(L, 1) != (int)lua_tonumber(L, 1)) {
        lua_pushstring(L, "register_hotspot expects (int, string, string)");
        lua_error(L);
    }
    
    HOTSPOT *hotspot = malloc(sizeof(HOTSPOT));
    hotspot->internal_name = strdup(lua_tostring(L, 2));
    hotspot->display_name = strdup(lua_tostring(L, 3));
    hotspot->cursor = 5;
    hotspot->exit = NULL;
    
    hotspots[(int)lua_tonumber(L, 1)] = hotspot;
    
    return 0;
}

int register_door(lua_State *L) {
    if (lua_gettop(L) != 4 || !lua_isstring(L, 1) || !lua_isstring(L, 2)|| !lua_isnumber(L, 3)  || !lua_isnumber(L, 4)) {
        lua_pushstring(L, "register_door expects (string, string, int, int)");
        lua_error(L);
    }
    
    HOTSPOT *hotspot = NULL;
    for (int i = 0; i < 256; i++)
        if (hotspots[i] && strcmp(hotspots[i]->internal_name, lua_tostring(L, 1)) == 0) {
            printf("found %s:%s\n", hotspots[i]->internal_name, lua_tostring(L, 1));
            hotspot = hotspots[i];
            break;
        }
        
    if (!hotspot) {
        lua_pushstring(L, "Could not find a registered hotspot to transform into a door. Are you missing a call to register_hotspot?");
        lua_error(L);
    }
    
    hotspot->cursor = lua_tonumber(L, 4);
    hotspot->exit = malloc(sizeof(EXIT));
    hotspot->exit->room = strdup(lua_tostring(L, 2));
    hotspot->exit->door = lua_tonumber(L, 3);
    
    return 0;
}

int lua_get_image_size(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_isuserdata(L, 1)) {
        lua_pushstring(L, "get_image_size expects (BITMAP*)");
        lua_error(L);
    }
    
    BITMAP *bmp = (BITMAP*)lua_touserdata(L, 1);
    if (bmp) {
        lua_pushnumber(L, bmp->w);
        lua_pushnumber(L, bmp->h);
    } else {
        lua_pushnumber(L, 0);
    lua_pushnumber(L, 0);
    }
    
    return 2;
}

int lua_get_bitmap(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_isstring(L, 1)) {
        lua_pushstring(L, "get_bitmap expects (string)");
        lua_error(L);
    }
    
    BITMAP *bmp = load_bitmap(lua_tostring(L, 1), NULL);
    if (!bmp) {
    printf("failed to load bitmap %s\n", lua_tostring(L, 1));
    }
    lua_pushlightuserdata(L, bmp);
    
    return 1;
}

int load_room(lua_State *L) {
    if (lua_gettop(L) != 2 || !lua_isuserdata(L, 1) || !lua_isuserdata(L, 2)) {
        lua_pushstring(L, "__load_room expects (BITMAP*, BITMAP*)");
        lua_error(L);
    }

    room_art = (BITMAP*)lua_touserdata(L, 1);
    room_hot = (BITMAP*)lua_touserdata(L, 2);
    
    for (int i = 0; i < 256; i++)
        if (hotspots[i] != NULL) {
            if (hotspots[i]->exit)
                free(hotspots[i]->exit);
            
            free(hotspots[i]);
            hotspots[i] = NULL;
        }

    build_walkspots();        
    build_waypoints();
        
    return 0;
}

int lua_panic(lua_State *L) {
    lua_Debug debug;
    lua_getstack(L, 1, &debug);
    lua_getinfo(L, "nS", &debug);
    
    printf("LUA ERROR: %s\nat %s\n", lua_tostring(L, 1), debug.name);
}

int lua_signal_goal(lua_State *L) {
    if (lua_gettop(L) != 0) {
        lua_pushstring(L, "signal_goal expects ()");
        lua_error(L);
    }
    
    door_travel = 0;
    
    return 0;
}

void init_script() {
    script = lua_open();
    luaL_openlibs(script);
    lua_atpanic(script, lua_panic);
    
    lua_newtable(script);
    lua_setregister(script, "render_obj");
    lua_newtable(script);
    lua_setregister(script, "render_inv");
    
    lua_register(script, "set_room_data", &load_room);
    lua_register(script, "register_hotspot", &register_hotspot);
    lua_register(script, "register_door", &register_door);
    lua_register(script, "get_image_size", &lua_get_image_size);
    lua_register(script, "get_bitmap", &lua_get_bitmap);
    lua_register(script, "signal_goal", &lua_signal_goal);
    
    register_path();
    
    luaL_dofile(script, "scripts/init.lua");
}
