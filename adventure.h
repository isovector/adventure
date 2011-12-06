#ifndef ADVENTURE_ADVENTURE_H
#define ADVENTURE_ADVENTURE_H

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <allegro.h>
#include <math.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <string.h>
#include <semaphore.h>

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
extern HOTSPOT *hotspots[256];
extern POINT *waypoints[MAX_WAYPOINTS];
extern int waypoint_count;
extern unsigned int waypoint_connections[MAX_WAYPOINTS];
extern int in_console;

void init_console(int);
void open_console();
char *strdup(const char*);

#endif
