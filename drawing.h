#ifndef ADVENTURE_DRAWING_H
#define ADVENTURE_DRAWING_H

#include "adventure.h"

int getpixel(SDL_Surface *surface, int x, int y);
void putpixel(SDL_Surface *surface, int x, int y, int color);

SDL_Surface *get_bitmap(const char*);
SDL_Surface *create_bitmap(int x, int y, int color);
void draw_blit(SDL_Surface *bmp, Vector *destv, bool flipped = false, Vector *srcv = NULL, Vector *size = NULL);
void draw_blit(SDL_Surface *target, SDL_Surface *bmp, Vector *destv, bool flipped = false, Vector *srcv = NULL, Vector *size = NULL);
void draw_circle(Vector *center, int radius, int color);
void draw_circle(SDL_Surface *target, Vector *center, int radius, int color);
void draw_ellipse(Vector *center, Vector *size, int color);
void draw_ellipse(SDL_Surface *target, Vector *center, Vector *size, int color);
void draw_line(Vector *start, Vector *end, int color);
void draw_line(SDL_Surface *target, Vector *start, Vector *end, int color);
void draw_point(Vector *pos, int color);
void draw_point(SDL_Surface *target, Vector *pos, int color);
void draw_text(Vector *pos, int fg, int bg, const char *str);
void draw_text(SDL_Surface *target, Vector *pos, int fg, int bg, const char *str);
void draw_text_center(Vector *pos, int fg, int bg, const char *str);
void draw_text_center(SDL_Surface *target, Vector *pos, int fg, int bg, const char *str);
void draw_clear(int color);
void draw_clear(SDL_Surface *target, int color);


extern SDL_Surface *screen;
extern TTF_Font *font, *font_outline;

#endif