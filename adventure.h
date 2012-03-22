#ifndef ADVENTURE_ADVENTURE_H
#define ADVENTURE_ADVENTURE_H

#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include <cstdlib>

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

#include <math.h>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

#include <semaphore.h>

using namespace std;

#define SCREEN_WIDTH 1280
#define SCREEN_HEIGHT 720
#define FRAMERATE 60
#define BITS_PER_PIXEL 0
#define OUTLINE_SIZE 2

typedef struct tagPOINT {
    int x, y;
} POINT;

#include "geometry.h"
#include "path.h"
#include "drawing.h"
#include "input.h"
#include "lua.h"

extern SDL_Surface *screen, *room_hot;
extern POINT *waypoints[MAX_WAYPOINTS];
extern int waypoint_count;
extern unsigned int waypoint_connections[MAX_WAYPOINTS];
extern bool in_console;
extern bool quit;

void init_console(int);
void open_console(int);

extern "C" {
    int luaopen_geometry(lua_State* L);
    int luaopen_newdrawing(lua_State* L);
}

#endif
