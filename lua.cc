#include "adventure.h"

lua_State *script;
std::map<int, std::string> key_mappings;

int script_load_room(lua_State *L) {
    int i;
    
    CALL_ARGS(2)
    CALL_TYPE(userdata)
    CALL_TYPE(userdata)
    CALL_ERROR("set_room_data expects (bitmap, bitmap)")

    room_art = *(SDL_Surface**)lua_touserdata(L, 1);
    room_hot = *(SDL_Surface**)lua_touserdata(L, 2);

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
    
    CALL_ARGS(1)
    CALL_TYPE(table)
    CALL_ERROR("which_hotspot expects (vector)")
    
    extract_vector(L, 1, &x, &y);
    
    lua_pushnumber(L, (getpixel(room_hot, x, y) & (255 << 16)) >> 16);
    return 1;
}

void update_mouse() {
    int mouse_x, mouse_y;
    int mouse_b = SDL_GetMouseState(&mouse_x, &mouse_y);
    
    
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
    lua_pushboolean(script, mouse_b & SDL_BUTTON(1));
    lua_settable(script, -3);
    lua_pushstring(script, "right");
    lua_pushboolean(script, mouse_b & SDL_BUTTON(3));
    lua_settable(script, -3);
    lua_pushstring(script, "middle");
    lua_pushboolean(script, mouse_b & SDL_BUTTON(2));
    lua_settable(script, -3);
    lua_pop(script, 3);
}

int script_get_key(lua_State *L) {
    CALL_ARGS(1)
    CALL_TYPE(string)
    CALL_ERROR("get_key expects (string)")
    
    // this seems REALLY fishy to me
    //lua_pushboolean(L, key[(int)lua_tonumber(L, 1)]);
    return 1;
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
    lua_register(script, "which_hotspot", &script_which_hotspot);
    lua_register(script, "get_key", &script_get_key);
    
    register_path();
    register_drawing();

    if (luaL_dofile(script, "scripts/environment.lua") != 0) {
		printf("%s\n", lua_tostring(script, -1));
	}
}

void init_keys() {
    lua_getglobal(script, "engine");
    lua_pushstring(script, "keys");
    lua_gettable(script, -2);
    
    lua_setkey(1);
    lua_setkey(2);
    lua_setkey(3);
    lua_setkey(4);
    lua_setkey(5);
    lua_setkey(6);
    lua_setkey(7);
    lua_setkey(8);
    lua_setkey(9);
    lua_setkey(0);
    
    lua_setkey(a);
    lua_setkey(b);
    lua_setkey(c);
    lua_setkey(d);
    lua_setkey(e);
    lua_setkey(f);
    lua_setkey(g);
    lua_setkey(h);
    lua_setkey(i);
    lua_setkey(j);
    lua_setkey(k);
    lua_setkey(l);
    lua_setkey(m);
    lua_setkey(n);
    lua_setkey(o);
    lua_setkey(p);
    lua_setkey(q);
    lua_setkey(r);
    lua_setkey(s);
    lua_setkey(t);
    lua_setkey(u);
    lua_setkey(v);
    lua_setkey(w);
    lua_setkey(x);
    lua_setkey(y);
    lua_setkey(z);
    
    lua_setkey(SPACE);
    
    lua_setkey(LEFT);
    lua_setkey(RIGHT);
    lua_setkey(UP);
    lua_setkey(DOWN);

    lua_pop(script, 2);
}

void update_key_state(int key, bool down) {
    lua_getglobal(script, "engine");
    lua_pushstring(script, "keys");
    lua_gettable(script, -2);
    
    lua_pushstring(script, key_mappings[key].c_str());
    lua_pushboolean(script, down);
    lua_settable(script, -3);
    
    if (down)
        lua_pushstring(script, "pressed");
    else
        lua_pushstring(script, "released");
    lua_gettable(script, -2);
    
    lua_pushstring(script, key_mappings[key].c_str());
    lua_pushboolean(script, true);
    lua_settable(script, -3);
    
    lua_pop(script, 3);
}

void boot_module() {
    string initcode = "module = dofile(\"module.lua\")\n"
                      "dofile(module .. \"/boot.lua\")\n"
                      "readonly.locks[\"module\"] = module";
    
    if (luaL_dostring(script, initcode.c_str()) != 0) {
		printf("%s\n", lua_tostring(script, -1));
	}
}
