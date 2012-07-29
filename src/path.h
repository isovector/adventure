#ifndef ADVENTURE_PATH_H
#define ADVENTURE_PATH_H

#include <map>

#include <SDL/SDL.h>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

#include "geometry.h"

#define MAX_WAYPOINTS 32

extern Vector *waypoints[MAX_WAYPOINTS];
extern unsigned int waypoint_connections[MAX_WAYPOINTS];
extern int waypoint_count;
extern int enabled_paths[256];

void connect_waypoints(int, int);
bool is_pathable(const Vector&, const Vector&);
void build_waypoints();
int get_neighbors(lua_State*);
int get_waypoint(lua_State*);
int get_closest_waypoint(lua_State*);
bool is_walkable(const Vector&);
int closest_waypoint(const Vector&);

std::map<int, int> *script_get_neighbors(int node);
Vector *script_get_waypoint(int waypointId);
int script_get_closest_waypoint(Vector *pos);
void script_enable_path(int path, bool enable = true);
int script_is_walkable(SDL_Surface *bmp, Vector *pos);
bool script_is_pathable(Vector *a, Vector *b);
int script_which_hotspot(Vector *pixel);
std::map<int, Vector*> *script_get_walkspots(SDL_Surface *bmp);

#endif
