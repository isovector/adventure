#include "adventure.h"

lua_State *script;

int script_load_room(lua_State *L) {
    int i;
    
    CALL_ARGS(1)
        CALL_TYPE(userdata)
    CALL_ERROR("set_room_data expects (bitmap)")

    room_hot = *(SDL_Surface**)lua_touserdata(L, 1);

    build_waypoints();
    
    lua_setconstant(L, "room_width", number, room_hot->w);
    lua_setconstant(L, "room_height", number, room_hot->h);
        
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
    
    CALL_ARGS(1)
    CALL_TYPE(table)
    CALL_ERROR("which_hotspot expects (vector)")
    
    extract_vector(L, 1, &x, &y);
    
    lua_pushnumber(L, (getpixel(room_hot, x, y) & (255 << 16)) >> 16);
    return 1;
}

void init_script() {
    script = lua_open();
    luaL_openlibs(script);
    luaopen_geometry(script);
    lua_atpanic(script, script_panic);
    
    lua_register(script, "set_room_data", &script_load_room);
    lua_register(script, "which_hotspot", &script_which_hotspot);
    
    register_path();
    register_drawing();

    if (luaL_dofile(script, "scripts/environment.lua") != 0)
		printf("%s\n", lua_tostring(script, -1));
}

void boot_module() {
    string initcode = "module = dofile(\"module.lua\")\n"
                      "dofile(module .. \"/boot.lua\")\n"
                      "readonly.locks[\"module\"] = module";
    
    if (luaL_dostring(script, initcode.c_str()) != 0)
		printf("%s\n", lua_tostring(script, -1));
}
