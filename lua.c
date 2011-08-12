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
    
    hotspots[(int)lua_tonumber(L, 1)] = hotspot;
    
    return 0;
}

int lua_get_image_size(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_isuserdata(L, 1)) {
        lua_pushstring(L, "get_image_size expects (BITMAP*)");
        lua_error(L);
    }
    
    BITMAP *bmp = (BITMAP*)lua_touserdata(L, 1);
    lua_pushnumber(L, bmp->w);
    lua_pushnumber(L, bmp->h);
    
    return 2;
}

int lua_get_bitmap(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_isstring(L, 1)) {
        lua_pushstring(L, "get_bitmap expects (string)");
        lua_error(L);
    }
    
    BITMAP *bmp = load_bitmap(lua_tostring(L, 1), NULL);
    printf("getting bitmap %d:%d\n", bmp->w, bmp->h);
    lua_pushlightuserdata(L, bmp);
    
    return 1;
}

int load_room(lua_State *L) {
    if (lua_gettop(L) != 2 || !lua_isstring(L, 1) || !lua_isstring(L, 2)) {
        lua_pushstring(L, "__load_room expects (string, string)");
        lua_error(L);
    }

    if (room_art != NULL) {
        destroy_bitmap(room_art);
        destroy_bitmap(room_hot);
    }
    
    room_art = load_bitmap(lua_tostring(L, 1), NULL);
    room_hot = load_bitmap(lua_tostring(L, 2), NULL);
	
	for (int i = 0; i < 256; i++)
        if (hotspots[i] != NULL) {
            free(hotspots[i]);
            hotspots[i] = NULL;
        }
        
    build_waypoints();
        
    return 0;
}

int lua_panic(lua_State *L) {
    lua_Debug debug;
    lua_getstack(L, 1, &debug);
    lua_getinfo(L, "nS", &debug);
    
    printf("LUA ERROR: %s\nat %s\n", lua_tostring(L, 1), debug.name);
}

void init_script() {
    script = lua_open();
    luaL_openlibs(script);
    lua_atpanic(script, lua_panic);
    
    lua_register(script, "__load_room", &load_room);
    lua_register(script, "register_hotspot", &register_hotspot);
    lua_register(script, "get_image_size", &lua_get_image_size);
    lua_register(script, "get_bitmap", &lua_get_bitmap);
    
    register_path();
    
    luaL_dofile(script, "scripts/init.lua");
}
