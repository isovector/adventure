#ifndef ADVENTURE_ADVENTURE_H
#define ADVENTURE_ADVENTURE_H

#ifdef	WIN32
#define ALLEGRO_USE_CONSOLE
#endif

#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include <assert.h>
#include <allegro.h>
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

typedef struct tagPOINT {
    int x, y;
} POINT;

typedef struct tagEXIT {
    const char *room;
    int door;
} EXIT;

typedef struct tagHOTSPOT {
    const char *internal_name;
    const char *display_name;
    int cursor;
    EXIT *exit;
} HOTSPOT;

#include "path.h"
#include "drawing.h"
#include "lua.h"

extern BITMAP *buffer;
extern BITMAP *room_art, *room_hot;
extern POINT *waypoints[MAX_WAYPOINTS];
extern int waypoint_count;
extern unsigned int waypoint_connections[MAX_WAYPOINTS];
extern int in_console;

void init_console(int);
void open_console(int);
char *strdup2(const char*);

#endif
