%module drawing
%{
#include "adventure.h"
%}

%include "exports/geometry.i"

struct SDL_Surface {
    %extend {
        Vector *size;
    }
};

%rename(load) get_bitmap;
SDL_Surface *get_bitmap(const char *file);

%rename(blit) draw_blit;
void draw_blit(SDL_Surface *bmp, Vector *destv, bool flipped = false, Vector *srcv = NULL, Vector *size = NULL);
void draw_blit(SDL_Surface *target, SDL_Surface *bmp, Vector *destv, bool flipped = false, Vector *srcv = NULL, Vector *size = NULL);

%rename(circle) draw_circle;
void draw_circle(Vector *center, int radius, int color);
void draw_circle(SDL_Surface *target, Vector *center, int radius, int color);

%rename(ellipse) draw_ellipse;
void draw_ellipse(Vector *center, Vector *size, int color);
void draw_ellipse(SDL_Surface *target, Vector *center, Vector *size, int color);

%rename(line) draw_line;
void draw_line(Vector *start, Vector *end, int color);
void draw_line(SDL_Surface *target, Vector *start, Vector *end, int color);

%rename(point) draw_point;
void draw_point(Vector *pos, int color);
void draw_point(SDL_Surface *target, Vector *pos, int color);

%rename(text) draw_text;
void draw_text(Vector *pos, int fg, int bg, const char *str);
void draw_text(SDL_Surface *target, Vector *pos, int fg, int bg, const char *str);

%rename(text_center) draw_text_center;
void draw_text_center(Vector *pos, int fg, int bg, const char *str);
void draw_text_center(SDL_Surface *target, Vector *pos, int fg, int bg, const char *str);

%rename(clear) draw_clear;
void draw_clear(int color);
void draw_clear(SDL_Surface *target, int color);

%rename(SDL_FreeSurface) free;
void SDL_FreeSurface(SDL_Surface *surface);

%{
Vector *SDL_Surface_size_get(SDL_Surface *surface) {
    return new Vector(surface->w, surface->h);
}

void SDL_Surface_size_set(SDL_Surface *surface, Vector *value) {
    // maybe we should have an error here?
}
%}

