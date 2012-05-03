#include "adventure.h"

SDL_Surface *screen;
TTF_Font *font;
TTF_Font *font_outline;
map<SDL_Surface*, SDL_Surface*> flipped_map;

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

SDL_Surface *make_bitmap(int w, int h) {
    unsigned int rmask, gmask, bmask, amask;
    
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
    
    return SDL_CreateRGBSurface(SDL_SWSURFACE, w, h, 32, rmask, gmask, bmask, amask);
}

SDL_Color translate_color(int int_color) {
    SDL_Color color = { 
        (int_color & 0xff0000) >> 16, 
        (int_color & 0x00ff00) >> 8,
        (int_color & 0x0000ff) >> 0
    };
    
    return color;
}

SDL_Surface* render_text(const char* str, int fgcolor, int bgcolor) {
    SDL_Surface *outline, *text, *temp;

    SDL_Rect dest;
    dest.x = OUTLINE_SIZE;
    dest.y = OUTLINE_SIZE;
    
    if (bgcolor != -1) {
        outline = TTF_RenderText_Solid(font_outline, str, translate_color(bgcolor));
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

SDL_Surface *get_bitmap(const char *file) {
    SDL_Surface *value, *temp;
    
    temp = IMG_Load(file);
    if (!temp) {
        return 0;
    }
    
    // HACK(sandy): biggest hack of my life.
    if (file[strlen(file) - 1] == 'g')
        value = SDL_DisplayFormatAlpha(temp);
    else
        value = SDL_DisplayFormat(temp);
    
    SDL_FreeSurface(temp);
    
    SDL_SetColorKey(value, SDL_SRCCOLORKEY | SDL_RLEACCEL, SDL_MapRGB(value->format, 255, 0, 255));
        
    return value;
}

void draw_blit(SDL_Surface *bmp, Vector *destv, bool flipped, Vector *srcv, Vector *size) {
    draw_blit(screen, bmp, destv, flipped, srcv, size);
}

void draw_blit(SDL_Surface *target, SDL_Surface *bmp, Vector *destv, bool flipped, Vector *srcv, Vector *size) {
    SDL_Rect src, dest;
    
    src.x = srcv ? srcv->x : 0;
    src.y = srcv ? srcv->y : 0;
    src.w = size ? size->x : bmp->w;
    src.h = size ? size->y : bmp->h;
     
    dest.x = destv->x;
    dest.y = destv->y;
    
    if (flipped) {
        if (flipped_map.find(bmp) == flipped_map.end())
            flipped_map[bmp] = rotozoomSurfaceXY(bmp, 0, -1, 1, SMOOTHING_OFF);
        
        bmp = flipped_map[bmp];
        src.x = bmp->w - src.x - src.w;
    }

    SDL_BlitSurface(bmp, &src, target, &dest);
}


SDL_Surface *create_bitmap(int x, int y, int color) {
    SDL_Surface *result;
    
    result = make_bitmap(x, y);
    
    if (!result)
        printf("failed to create bitmap\n");

    SDL_FillRect(result, NULL, color);
    SDL_SetColorKey(result, SDL_SRCCOLORKEY | SDL_RLEACCEL, SDL_MapRGB(result->format, 255, 0, 255));
    
    return result;
}

void draw_circle(Vector *center, int radius, int color) {
    draw_circle(screen, center, radius, color);
}

void draw_circle(SDL_Surface *target, Vector *center, int radius, int color) {
    circleColor(target, center->x, center->y, radius, color);
}

void draw_ellipse(Vector *center, Vector *size, int color) {
    draw_ellipse(screen, center, size, color);
}

void draw_ellipse(SDL_Surface *target, Vector *center, Vector *size, int color) {
    ellipseColor(target, center->x, center->y, size->x, size->y, color);
}

void draw_line(Vector *start, Vector *end, int color) {
    draw_line(screen, start, end, color);
}

void draw_line(SDL_Surface *target, Vector *start, Vector *end, int color) {
    lineColor(target, start->x, start->y, end->x, end->y, color);
}

void draw_point(Vector *pos, int color) {
    draw_point(screen, pos, color);
}

void draw_point(SDL_Surface *target, Vector *pos, int color) {
    putpixel(target, pos->x, pos->y, color);
}

void draw_text(Vector *pos, int fg, int bg, const char *str) {
    draw_text(screen, pos, fg, bg, str);
}

void draw_text(SDL_Surface *target, Vector *pos, int fg, int bg, const char *str) {
    SDL_Surface *text = render_text(str, fg, bg);
    
    SDL_Rect dest;
    dest.x = pos->x;
    dest.y = pos->y;
    
    SDL_BlitSurface(text, NULL, target, &dest);
    SDL_FreeSurface(text);
}

void draw_text_center(Vector *pos, int fg, int bg, const char *str) {
    draw_text_center(screen, pos, fg, bg, str);
}

void draw_text_center(SDL_Surface *target, Vector *pos, int fg, int bg, const char *str) {
    SDL_Surface *text = render_text(str, fg, bg);
    
    SDL_Rect dest;
    dest.x = pos->x - text->w / 2;
    dest.y = pos->y;
    
    SDL_BlitSurface(text, NULL, target, &dest);
    SDL_FreeSurface(text);
}

void draw_clear(int color) {
    draw_clear(screen, color);
}

void draw_clear(SDL_Surface *target, int color) {
    SDL_FillRect(target, NULL, color);
}
