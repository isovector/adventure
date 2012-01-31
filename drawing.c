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
    int w, h;
    BITMAP *tmp, *bmp;
    
    if (lua_gettop(L) != 8 || !lua_isuserdata(L, 1) || !lua_isnumber(L, 2)
        || !lua_isnumber(L, 3) || !lua_isboolean(L, 4) || !lua_isnumber(L, 5)
        || !lua_isnumber(L, 6) || !lua_isnumber(L, 7) || !lua_isnumber(L, 8)) {
        lua_pushstring(L, "drawing.blit expects (bitmap, int, int, boolean, int, int, int, int)");
        lua_error(L);
    }
    
    w = lua_tonumber(L, 7), h = lua_tonumber(L, 8);
    
    tmp = create_bitmap(w, h);
    bmp = *(BITMAP**)lua_touserdata(L, 1);

    blit(bmp, tmp, lua_tonumber(L, 5), lua_tonumber(L, 6), 0, 0, w, h);
    draw_sprite_ex(buffer, tmp, lua_tonumber(L, 2), lua_tonumber(L, 3), DRAW_SPRITE_NORMAL, lua_toboolean(L, 4));
    
    destroy_bitmap(tmp);
    
    return 0;
}

int script_draw_circle(lua_State *L) {
    int x, y, radius, color;
    
    if (lua_gettop(L) != 3 || !lua_istable(L, 1) || !lua_isnumber(L, 2) || !lua_isnumber(L, 2)) {
        lua_pushstring(L, "drawing.circle expects (vector, int, int)");
        lua_error(L);
    }
    
    extract_vector(L, 1, &x, &y);
    circle(buffer, x, y, lua_tonumber(L, 2), lua_tonumber(L, 3));
    
    return 0;
}

int script_draw_rect(lua_State *L) {
    int x, y, w, h;
    
    if (lua_gettop(L) != 2 || !lua_istable(L, 1) || !lua_isnumber(L, 2)) {
        lua_pushstring(L, "drawing.rect expects (rect, number)");
        lua_error(L);
    }
    
    lua_pushstring(L, "pos");
    lua_gettable(L, 1);
    extract_vector(L, -1, &x, &y);
    lua_pop(L, 1);
    
    lua_pushstring(L, "size");
    lua_gettable(L, 1);
    extract_vector(L, -1, &w, &h);
    lua_pop(L, 1);
    
    rect(buffer, x, y, x + w, y + h, lua_tonumber(L, 2));
    
    return 0;
}

int script_draw_line(lua_State *L) {
    int x1, y1, x2, y2, color;
    
    if (lua_gettop(L) != 3 || !lua_istable(L, 1) || !lua_istable(L, 2) || !lua_isnumber(L, 3)) {
        lua_pushstring(L, "drawing.line expects (vector, vector, int)");
        lua_error(L);
    }
    
    extract_vector(L, 1, &x1, &y1);
    extract_vector(L, 2, &x2, &y2);
    line(buffer, x1, y1, x2, y2, lua_tonumber(L, 3));
    
    return 0;
}

int script_draw_polygon(lua_State *L) {
    int i, n, x, y, *vertices, color;
    
    if (lua_gettop(L) != 2 || !lua_istable(L, 1) || !lua_isnumber(L, 2)) {
        lua_pushstring(L, "drawing.polygon expects (vector[], int)");
        lua_error(L);
    }
    
    lua_getglobal(L, "table");
    lua_pushstring(L, "getn");
    lua_gettable(L, -2);
    lua_pushvalue(L, 1);
    lua_call(L, 1, 1);
    n = lua_tonumber(L, -1);
    lua_pop(L, 2);
    
    lua_pushvalue(L, 1);
    vertices = (int*)malloc(n * 2 * sizeof(int));
    
    for (i = 1; i <= n; i++) {
        lua_pushnumber(L, i);
        lua_gettable(L, -2);
        extract_vector(L, -1, &x, &y);
        lua_pop(L, 1);
        
        vertices[(i - 1) * 2] = x;
        vertices[(i - 1) * 2 + 1] = y;
    }
    
    polygon(buffer, n, vertices, lua_tonumber(L, 2));
    free(vertices);
    
    return 0;
}

int script_blit_rotate(lua_State *L) {
    int cx, cy, x, y, angle;
    BITMAP *bmp;
    
    if (lua_gettop(L) != 5 || !lua_isuserdata(L, 1) || !lua_istable(L, 2) || !lua_istable(L, 3) || !lua_isnumber(L, 4) || !lua_isnumber(L, 5)) {
        lua_pushstring(L, "drawing.blit_rotate expects (bitmap, vector, vector, int)");
        lua_error(L);
    }
    
    bmp = *(BITMAP**)lua_touserdata(L, 1);
    
    extract_vector(L, 2, &x, &y);
    extract_vector(L, 3, &cx, &cy);
    
    pivot_scaled_sprite(buffer, bmp, x, y, cx, cy, itofix(lua_tonumber(L, 4)), ftofix(lua_tonumber(L, 5)));
    
    return 0;
}

int script_get_bitmap(lua_State *L) {
    BITMAP** userdata;
    
    if (lua_gettop(L) != 1 || !lua_isstring(L, 1)) {
        lua_pushstring(L, "bitmap expects (string)");
        lua_error(L);
    }
    
    userdata = (BITMAP**)lua_newuserdata(L, sizeof(BITMAP*));
    *userdata = load_bitmap(lua_tostring(L, 1), NULL);
    
    if (!*userdata)
        printf("failed to load bitmap %s\n", lua_tostring(L, 1));
    
    luaL_newmetatable(script, "adventure.bitmap");
    lua_setmetatable(script, -2);
    
    return 1;
}

int script_bitmap_size(lua_State *L) {
    BITMAP *bmp;
    
    if (strcmp(lua_tostring(L, 2), "size") != 0) {
        lua_pushstring(L, "bitmap contains only the `size` member");
        lua_error(L);
    }
    
    bmp = *(BITMAP**)lua_touserdata(L, 1);
    
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
    lua_regtable(script, "drawing", "circle", script_draw_circle);
    lua_regtable(script, "drawing", "line", script_draw_line);
    lua_regtable(script, "drawing", "rect", script_draw_rect);
    lua_regtable(script, "drawing", "polygon", script_draw_polygon);
    lua_regtable(script, "drawing", "raw_text", script_draw_text);
    lua_regtable(script, "drawing", "raw_text_center", script_draw_text_center);
    lua_regtable(script, "drawing", "raw_blit", script_draw_blit);
    lua_regtable(script, "drawing", "blit_rotate", script_blit_rotate);
    
    lua_register(script, "bitmap", &script_get_bitmap);
}