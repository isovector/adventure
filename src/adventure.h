#ifndef ADVENTURE_ADVENTURE_H
#define ADVENTURE_ADVENTURE_H

#include <assert.h>

#ifdef WIN32
#include <SDL.h>
#undef main
#include <SDL_rotozoom.h>
#include <SDL_gfxPrimitives.h>
#include <SDL_image.h>
#include <SDL_ttf.h>

#else
#include <SDL/SDL.h>
#include <SDL/SDL_rotozoom.h>
#include <SDL/SDL_gfxPrimitives.h>
#include <SDL/SDL_image.h>
#include <SDL/SDL_ttf.h>

#endif


extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}



#define SCREEN_WIDTH 1280
#define SCREEN_HEIGHT 720
#define FRAMERATE 60
#define BITS_PER_PIXEL 0

#include "geometry.h"


extern SDL_Surface *screen, *room_hot;

extern bool in_console;

void init_console(int);
void open_console(int);



#endif
