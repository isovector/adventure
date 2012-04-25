#include "adventure.h"

lua_State *script;

int script_panic(lua_State* L) {
    lua_Debug entry;
    int depth = 0; 
    
    printf("ERROR: %s\n", lua_tostring(L, -1));

    while (lua_getstack(L, depth, &entry)) {
        int status = lua_getinfo(L, "Sln", &entry);
		assert(status);

		printf("%s(%d): %s\n", entry.short_src, entry.currentline, entry.name ? entry.name : "?");
        depth++;
    }
    
    return 0;
}

void load_room(SDL_Surface *hot) {
    room_hot = hot;
    build_waypoints();
    
    lua_setconstant(script, "room_width", number, room_hot->w);
    lua_setconstant(script, "room_height", number, room_hot->h);
}

void init_script() {
    script = lua_open();
    
    luaL_openlibs(script);
    luaopen_geometry(script);
    luaopen_drawing(script);
    luaopen_pathfinding(script);
    
    lua_atpanic(script, script_panic);
    
    if (luaL_dofile(script, "scripts/environment.lua") != 0)
		printf("%s\n", lua_tostring(script, -1));
}

void boot_module(string module) {
    lua_pushstring(script, module.c_str());
    lua_setglobal(script, "module");
    
    string initcode = "dofile(module .. \"/boot.lua\")\n"
                      "readonly.locks[\"module\"] = module";
    
    if (luaL_dostring(script, initcode.c_str()) != 0)
		printf("%s\n", lua_tostring(script, -1));
}
