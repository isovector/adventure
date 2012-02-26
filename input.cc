#include "adventure.h"

std::map<int, std::string> key_mappings;

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

char getUnicodeValue( const SDL_KeyboardEvent &key )
{
    assert( SDL_EnableUNICODE(SDL_QUERY) == SDL_ENABLE );
    // magic numbers courtesy of SDL docs :)
    const int INTERNATIONAL_MASK = 0xFF80, UNICODE_MASK = 0x7F;

    int uni = key.keysym.unicode;

    if( uni == 0 ) // not translatable key (like up or down arrows)
    {
        // probably not useful as string input
        // we could optionally use this to get some value
        // for it: SDL_GetKeyName( key );
        return 0;
    }
    else if( ( uni & INTERNATIONAL_MASK ) == 0 )
    {
        if( SDL_GetModState() & KMOD_SHIFT )
        {
            return static_cast<char>(toupper(uni & UNICODE_MASK));
        }
        else
        {
            return static_cast<char>(uni & UNICODE_MASK);
        }
    }
    else // we have a funky international character. one we can't read :(
    {
        // we could do nothing, or we can just show some sign of input, like so:
        // return '?';
        return 0;
    }
}
