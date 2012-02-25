#ifndef ADVENTURE_DRAWING_H
#define ADVENTURE_DRAWING_H

#include "adventure.h"

void register_drawing();
int getpixel(SDL_Surface *surface, int x, int y);
void putpixel(SDL_Surface *surface, int x, int y, int color);

extern SDL_Surface *screen;
extern TTF_Font *font;

#endif