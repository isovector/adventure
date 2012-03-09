#include "adventure.h"

SDL_Surface *screen;
TTF_Font *font;

int getpixel(SDL_Surface *surface, int x, int y) {
    int bpp = surface->format->BytesPerPixel;
    return *((int*)surface->pixels + y * surface->pitch / bpp + x);
}

void putpixel(SDL_Surface *surface, int x, int y, int color) {
    int bpp = surface->format->BytesPerPixel;
    *((int*)surface->pixels + y * surface->pitch / bpp + x) = color;
}


SDL_Surface *get_target(lua_State *L, int size) {
    SDL_Surface *target = screen;
    
    if (lua_gettop(L) == size + 1 && lua_isuserdata(L, 1)) {
        target = *(SDL_Surface**)lua_touserdata(L, 1);
        lua_remove(L, 1);
    }
    
    return target;
}

SDL_Color translate_color(int int_color) {
    SDL_Color color = { 
        (int_color & 0xff0000) >> 16, 
        (int_color & 0x00ff00) >> 8,
        (int_color & 0x0000ff) >> 0
    };
    
    return color;
}

int script_draw_clear(lua_State *L) {
    SDL_Surface *target = get_target(L, 1);
    
    CALL_ARGS(1)
    CALL_TYPE(number)
    CALL_ERROR("drawing.clear expects (int)")
    
    SDL_FillRect(target, NULL, lua_tonumber(L, -1));
    
    return 0;
}

SDL_Surface* render_text(const char* str, int fgcolor, int bgcolor) {
    static const int OUTLINE_SIZE = 2;
    
    SDL_Surface *outline, *text, *temp;

    SDL_Rect dest;
    dest.x = OUTLINE_SIZE;
    dest.y = OUTLINE_SIZE;
    
    if (bgcolor != -1) {
        TTF_SetFontOutline(font, OUTLINE_SIZE);
        outline = TTF_RenderText_Solid(font, str, translate_color(bgcolor));
        
        TTF_SetFontOutline(font, 0);
    }
    
    text = TTF_RenderText_Solid(font, str, translate_color(fgcolor));
    
    if (bgcolor != -1) {
        temp = SDL_DisplayFormat(outline);
        SDL_BlitSurface(text, NULL, temp, &dest);
        SDL_FreeSurface(text);
        SDL_FreeSurface(outline);
        
        return temp;
    }
    
    return text;
}

int script_draw_text(lua_State *L) {
    SDL_Surface *target = get_target(L, 5), *text;
    
    CALL_ARGS(5)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(string)
    CALL_ERROR("drawing.text expects (int, int, int, int, string)")

    text = render_text(lua_tostring(L, 5), (int)lua_tonumber(L, 3), (int)lua_tonumber(L, 4));
    
    SDL_Rect dest;
    dest.x = lua_tonumber(L, 1);
    dest.y = lua_tonumber(L, 2);
    
    SDL_BlitSurface(text, NULL, target, &dest);
    SDL_FreeSurface(text);
    
    return 0;
}

int script_draw_text_center(lua_State *L) {
    static const int OUTLINE_SIZE = 2;
    
    SDL_Surface *target = get_target(L, 5), *text;
    
    CALL_ARGS(5)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(string)
    CALL_ERROR("drawing.text expects (int, int, int, int, string)")
    
    text = render_text(lua_tostring(L, 5), (int)lua_tonumber(L, 3), (int)lua_tonumber(L, 4));
    
    SDL_Rect dest;
    dest.x = lua_tonumber(L, 1) - text->w / 2;
    dest.y = lua_tonumber(L, 2);
    
    SDL_BlitSurface(text, NULL, target, &dest);
    SDL_FreeSurface(text);
    
    return 0;
}

int script_draw_blit(lua_State *L) {
    SDL_Surface *bmp;
    SDL_Surface *target = get_target(L, 8);
    
    CALL_ARGS(8)
    CALL_TYPE(userdata)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(boolean)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_ERROR("drawing.text expects (bitmap, int, int, bool, int, int, int, int)")
    
    bmp = *(SDL_Surface**)lua_touserdata(L, 1);

    SDL_Rect src, dest;
    src.x = lua_tonumber(L, 5);
    src.y = lua_tonumber(L, 6);
    src.w = lua_tonumber(L, 7);
    src.h = lua_tonumber(L, 8);
     
    dest.x = lua_tonumber(L, 2);
    dest.y = lua_tonumber(L, 3);
    
    // TODO(sandy): fix flipping
    /*if (lua_toboolean(L, 4)) {
        bmp = rotozoomSurfaceXY(bmp, 0, -1, 1, SMOOTHING_OFF);
    }*/
    
    SDL_BlitSurface(bmp, &src, target, &dest);
    
    /*if (lua_toboolean(L, 4)) {
        SDL_FreeSurface(bmp);
    }*/
    
    return 0;
}

int script_draw_get_text(lua_State *L) {
    SDL_Surface **userdata;
    
    CALL_ARGS(3)
    CALL_TYPE(string)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_ERROR("drawing.get_text expects (string, int, int)")
    
    userdata = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
    *userdata = render_text(lua_tostring(L, 1), (int)lua_tonumber(L, 2), (int)lua_tonumber(L, 3));
    
    if (!*userdata)
        printf("failed to create bitmap\n");

    luaL_newmetatable(L, "adventure.bitmap");
    lua_setmetatable(L, -2);
    
    return 1;
}

int script_draw_circle(lua_State *L) {
    int x, y, radius, color;
    SDL_Surface *target = get_target(L, 3);
    
    CALL_ARGS(3)
    CALL_TYPE(table)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_ERROR("drawing.circle expects (vector, int, int)")
    
    extract_vector(L, 1, &x, &y);
    circleColor(target, x, y, lua_tonumber(L, 2), lua_tonumber(L, 3));
    
    return 0;
}

int script_draw_ellipse(lua_State *L) {
    int x, y, rx, ry, color;
    SDL_Surface *target = get_target(L, 3);
    
    CALL_ARGS(3)
    CALL_TYPE(table)
    CALL_TYPE(table)
    CALL_TYPE(number)
    CALL_ERROR("drawing.ellipse expects (vector, vector, int)")
    
    extract_vector(L, 1, &x, &y);
    extract_vector(L, 2, &rx, &ry);
    ellipseColor(target, x, y, rx, ry, lua_tonumber(L, 3));
    
    return 0;
}

int script_draw_rect(lua_State *L) {
    int x, y, w, h;
    SDL_Surface *target = get_target(L, 2);
    
    CALL_ARGS(2)
    CALL_TYPE(table)
    CALL_TYPE(number)
    CALL_ERROR("drawing.rect expects (rect, int)")
        
    lua_pushstring(L, "pos");
    lua_gettable(L, 1);
    extract_vector(L, -1, &x, &y);
    lua_pop(L, 1);
    
    lua_pushstring(L, "size");
    lua_gettable(L, 1);
    extract_vector(L, -1, &w, &h);
    lua_pop(L, 1);
    
    rectangleColor(target, x, y, x + w, y + h, lua_tonumber(L, 2));
    
    return 0;
}

int script_draw_line(lua_State *L) {
    int x1, y1, x2, y2, color;
    SDL_Surface *target = get_target(L, 3);
    
    CALL_ARGS(3)
    CALL_TYPE(table)
    CALL_TYPE(table)
    CALL_TYPE(number)
    CALL_ERROR("drawing.line expects (vector, vector, int)")
    
    extract_vector(L, 1, &x1, &y1);
    extract_vector(L, 2, &x2, &y2);
    lineColor(target, x1, y1, x2, y2, lua_tonumber(L, 3));
    
    return 0;
}

int script_draw_point(lua_State *L) {
    int x, y;
    SDL_Surface *target = get_target(L, 2);
    
    CALL_ARGS(2)
    CALL_TYPE(table)
    CALL_TYPE(number)
    CALL_ERROR("drawing.point expects (vector, int)")
    
    extract_vector(L, 1, &x, &y);
    
    putpixel(target, x, y, lua_tonumber(L, 2));
    
    return 0;
}

int script_draw_polygon(lua_State *L) {
    int i, n, x, y, color;
    int vertices[1024];
    SDL_Surface *target = get_target(L, 2);
    
    CALL_ARGS(2)
    CALL_TYPE(table)
    CALL_TYPE(number)
    CALL_ERROR("drawing.polygon expects (vector[], int)")
    
    lua_getglobal(L, "table");
    lua_pushstring(L, "getn");
    lua_gettable(L, -2);
    lua_pushvalue(L, 1);
    lua_call(L, 1, 1);
    n = lua_tonumber(L, -1);
    lua_pop(L, 2);
    
    lua_pushvalue(L, 1);
    
    for (i = 1; i <= n; i++) {
        lua_pushnumber(L, i);
        lua_gettable(L, -2);
        extract_vector(L, -1, &x, &y);
        lua_pop(L, 1);
        
        vertices[(i - 1) * 2] = x;
        vertices[(i - 1) * 2 + 1] = y;
    }
    
    //polygon(target, n, vertices, lua_tonumber(L, 2));
    
    return 0;
}

int script_blit_rotate(lua_State *L) {
    int cx, cy, x, y, angle;
    SDL_Surface *target = get_target(L, 5);
    
    CALL_ARGS(5)
    CALL_TYPE(userdata)
    CALL_TYPE(table)
    CALL_TYPE(table)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_ERROR("drawing.blit_rotate expects (bitmap, vector, vector, int, int)")
        
    target = *(SDL_Surface**)lua_touserdata(L, 1);
    
    extract_vector(L, 2, &x, &y);
    extract_vector(L, 3, &cx, &cy);
    
    //pivot_scaled_sprite(target, target, x, y, cx, cy, itofix(lua_tonumber(L, 4)), ftofix(lua_tonumber(L, 5)));
    
    return 0;
}

int script_draw_free(lua_State *L) {
    CALL_ARGS(1)
    CALL_TYPE(userdata)
    CALL_ERROR("drawing.free expects (bitmap)")
            
    SDL_FreeSurface(*(SDL_Surface**)lua_touserdata(L, 1));
    
    return 0;
}

int script_get_bitmap(lua_State *L) {
    SDL_Surface** userdata, *temp;
    
    CALL_ARGS(1)
    CALL_TYPE(string)
    CALL_ERROR("bitmap expects (string)")      

    temp = IMG_Load(lua_tostring(L, 1));
    if (!temp) {
        printf("failed to load bitmap %s\n", lua_tostring(L, 1));
        return 0;
    }
     
    userdata = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
    *userdata = SDL_DisplayFormat(temp);
    SDL_FreeSurface(temp);
    
    SDL_SetColorKey(*userdata, SDL_SRCCOLORKEY | SDL_RLEACCEL, SDL_MapRGB((*userdata)->format, 255, 0, 255));
    luaL_newmetatable(script, "adventure.bitmap");
    lua_setmetatable(script, -2);
    
    return 1;
}

int script_create_bitmap(lua_State *L) {
    SDL_Surface** userdata;
    uint rmask, gmask, bmask, amask;
    
    CALL_ARGS(3)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_TYPE(number)
    CALL_ERROR("drawing.create_bitmap expects (int, int, int)")    
    
    /* SDL interprets each pixel as a 32-bit number, so our masks must depend
       on the endianness (byte order) of the machine */
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
    rmask = 0xff000000;
    gmask = 0x00ff0000;
    bmask = 0x0000ff00;
    amask = 0x000000ff;
#else
    rmask = 0x000000ff;
    gmask = 0x0000ff00;
    bmask = 0x00ff0000;
    amask = 0xff000000;
#endif
    
    userdata = (SDL_Surface**)lua_newuserdata(L, sizeof(SDL_Surface*));
    *userdata = SDL_CreateRGBSurface(SDL_SWSURFACE, lua_tonumber(L, 1), lua_tonumber(L, 2), 32, rmask, gmask, bmask, amask);
    
    if (!*userdata)
        printf("failed to create bitmap\n");

    SDL_FillRect(*userdata, NULL, lua_tonumber(L, 3));
    
    luaL_newmetatable(script, "adventure.bitmap");
    lua_setmetatable(script, -2);
    
    return 1;
}

int script_bitmap_size(lua_State *L) {
    SDL_Surface *target;
    
    if (strcmp(lua_tostring(L, 2), "size") != 0) {
        lua_pushstring(L, "bitmap contains only the `size` member");
        lua_error(L);
    }
    
    target = *(SDL_Surface**)lua_touserdata(L, 1);
    
    lua_getglobal(L, "vec");
    lua_pushnumber(L, target->w);
    lua_pushnumber(L, target->h);
    
    lua_call(L, 2, 1);
    
    return 1;
}

int script_draw_set_mode(lua_State *L) {
    CALL_ARGS(1)
    CALL_TYPE(number)
    CALL_ERROR("drawing.set_mode expects (int)")

    //drawing_mode(lua_tonumber(L, 1), NULL, 0, 0);
    
    return 0;
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
    lua_regtable(script, "drawing", "ellipse", script_draw_ellipse);
    lua_regtable(script, "drawing", "free", script_draw_free);
    lua_regtable(script, "drawing", "get_text", script_draw_get_text);
    lua_regtable(script, "drawing", "line", script_draw_line);
    lua_regtable(script, "drawing", "point", script_draw_point);
    lua_regtable(script, "drawing", "rect", script_draw_rect);
    lua_regtable(script, "drawing", "polygon", script_draw_polygon);
    lua_regtable(script, "drawing", "raw_text", script_draw_text);
    lua_regtable(script, "drawing", "raw_text_center", script_draw_text_center);
    lua_regtable(script, "drawing", "raw_blit", script_draw_blit);
    lua_regtable(script, "drawing", "raw_set_mode", script_draw_set_mode);
    lua_regtable(script, "drawing", "blit_rotate", script_blit_rotate);
    
    lua_register(script, "bitmap", &script_get_bitmap);
    lua_register(script, "create_bitmap", &script_create_bitmap);
}