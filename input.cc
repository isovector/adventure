#include "adventure.h"

bool text_mode = false;
std::map<int, std::string> key_mappings;
string input_string = "";

void set_text_input_mode(bool enabled) {
    text_mode = enabled;
    SDL_EnableUNICODE(text_mode ? SDL_ENABLE : SDL_DISABLE);
    
    if (enabled)
        SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL);
    else
        SDL_EnableKeyRepeat(0, 0);
}

char event_to_char(const SDL_KeyboardEvent &key) {
    static const int INTERNATIONAL_MASK = 0xFF80, UNICODE_MASK = 0x7F;
    
    int uni = key.keysym.unicode;
    if (uni == 0 || (uni & INTERNATIONAL_MASK) != 0) // no usable unicode value
        return 0;

    return uni & UNICODE_MASK;
}

void process_text_input(const SDL_KeyboardEvent &event) {
    char c;

    if (event.keysym.sym == SDLK_BACKSPACE && input_string.length() > 0)
        input_string.erase(input_string.size() - 1);
    else if (c = event_to_char(event))
        input_string += c;
}

void process_input_event(const SDL_Event &event) {
    switch (event.type) {
        case SDL_KEYDOWN: {
            if (event.key.keysym.sym == SDLK_ESCAPE)
                quit = true;
            else if (text_mode)
                process_text_input(event.key);
            else if (event.key.keysym.sym == SDLK_F10) {
                //open_console(1);
            } else
                update_key_state(event.key.keysym.sym, true);
        } break;

        case SDL_KEYUP: {
            if (!text_mode)
                update_key_state(event.key.keysym.sym, false);
        } break;
        
        case SDL_QUIT: {
            quit = true;
        } break;

        default: {
        } break;
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
