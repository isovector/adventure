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
    BITMAP *bmp = *(BITMAP**)lua_touserdata(L, 1);

    blit(bmp, tmp, lua_tonumber(L, 5), lua_tonumber(L, 6), 0, 0, w, h);
    draw_sprite_ex(buffer, tmp, lua_tonumber(L, 2), lua_tonumber(L, 3), DRAW_SPRITE_NORMAL, lua_toboolean(L, 4));
    
    destroy_bitmap(tmp);
    
    return 0;
}

int script_get_image_size(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_isuserdata(L, 1)) {
        lua_pushstring(L, "get_image_size expects (BITMAP*)");
        lua_error(L);
    }
    
    BITMAP *bmp = *(BITMAP**)lua_touserdata(L, 1);
    if (bmp) {
        lua_pushnumber(L, bmp->w);
        lua_pushnumber(L, bmp->h);
    } else {
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
    }
    
    return 2;
}

int script_get_bitmap(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_isstring(L, 1)) {
        lua_pushstring(L, "bitmap expects (string)");
        lua_error(L);
    }
    
    BITMAP** userdata = (BITMAP**)lua_newuserdata(L, sizeof(BITMAP*));
    *userdata = load_bitmap(lua_tostring(L, 1), NULL);
    
    if (!*userdata)
        printf("failed to load bitmap %s\n", lua_tostring(L, 1));
    
    luaL_newmetatable(script, "adventure.bitmap");
    lua_setmetatable(script, -2);
    
    return 1;
}

int script_bitmap_size(lua_State *L) {
    if (strcmp(lua_tostring(L, 2), "size") != 0) {
        lua_pushstring(L, "bitmap contains only the `size` member");
        lua_error(L);
    }
    
    BITMAP *bmp = *(BITMAP**)lua_touserdata(L, 1);
    
    lua_getglobal(L, "vec");
    lua_pushnumber(L, bmp->w);
    lua_pushnumber(L, bmp->h);
    
    lua_call(L, 2, 1);
    
    return 1;
}

void register_drawing() {
    lua_newtable(script);
    lua_setglobal(script, "drawing");
    
    luaL_newmetatable(script, "adventure.bitmap");
    lua_pushstring(script, "__index");
    lua_pushcfunction(script, &script_bitmap_size);
    lua_settable(script, -3);
    lua_pop(script, 1);
    
    lua_regtable(script, "drawing", "clear", script_draw_clear);
    lua_regtable(script, "drawing", "raw_text", script_draw_text);
    lua_regtable(script, "drawing", "raw_text_center", script_draw_text_center);
    lua_regtable(script, "drawing", "raw_blit", script_draw_blit);
    
    lua_register(script, "bitmap", &script_get_bitmap);
}