#include "adventure.h"

BITMAP *buffer;

int script_draw_clear(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_isnumber(L, 1)) {
        lua_pushstring(L, "drawing.clear expects (int)");
        lua_error(L);
    }
    
    clear_to_color(buffer, lua_tonumber(L, -1));
    
    return 0;
}

int script_draw_text(lua_State *L) {
    if (lua_gettop(L) != 5 || !lua_isnumber(L, 1) || !lua_isnumber(L, 2)
        || !lua_isnumber(L, 3) || !lua_isnumber(L, 4) || !lua_isstring(L, 5)) {
        lua_pushstring(L, "drawing.text expects (int, int, int, int, string)");
        lua_error(L);
    }
    
    textout_ex(buffer, font, lua_tostring(L, 5), lua_tonumber(L, 1), lua_tonumber(L, 2), lua_tonumber(L, 3), lua_tonumber(L, 4));

    return 0;
}

int script_draw_text_center(lua_State *L) {
    if (lua_gettop(L) != 5 || !lua_isnumber(L, 1) || !lua_isnumber(L, 2)
        || !lua_isnumber(L, 3) || !lua_isnumber(L, 4) || !lua_isstring(L, 5)) {
        lua_pushstring(L, "drawing.text expects (int, int, int, int, string)");
        lua_error(L);
    }
    
    textout_centre_ex(buffer, font, lua_tostring(L, 5), lua_tonumber(L, 1), lua_tonumber(L, 2), lua_tonumber(L, 3), lua_tonumber(L, 4));

    return 0;
}

int script_draw_blit(lua_State *L) {
    if (lua_gettop(L) != 8 || !lua_isuserdata(L, 1) || !lua_isnumber(L, 2)
        || !lua_isnumber(L, 3) || !lua_isboolean(L, 4) || !lua_isnumber(L, 5)
        || !lua_isnumber(L, 6) || !lua_isnumber(L, 7) || !lua_isnumber(L, 8)) {
        lua_pushstring(L, "drawing.blit expects (BITMAP*, int, int, boolean, int, int, int, int)");
        lua_error(L);
    }
    
    int w = lua_tonumber(L, 7), h = lua_tonumber(L, 8);
    
    BITMAP *tmp = create_bitmap(w, h);
    blit((BITMAP*)lua_touserdata(L, 1), tmp, lua_tonumber(L, 5), lua_tonumber(L, 6), 0, 0, w, h);
    draw_sprite_ex(buffer, tmp, lua_tonumber(L, 2), lua_tonumber(L, 3), DRAW_SPRITE_NORMAL, lua_toboolean(L, 4));
    
    destroy_bitmap(tmp);
    
    return 0;
}

void register_drawing() {
    lua_newtable(script);
    lua_setglobal(script, "drawing");
    
    lua_regtable(script, "drawing", "clear", script_draw_clear);
    lua_regtable(script, "drawing", "raw_text", script_draw_text);
    lua_regtable(script, "drawing", "raw_text_center", script_draw_text_center);
    lua_regtable(script, "drawing", "raw_blit", script_draw_blit);
}