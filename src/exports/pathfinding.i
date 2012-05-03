%module pathfinding
%{
#include "adventure.h"

int script_map_out(map<int, int> *table) {
    lua_newtable(script);
    for (map<int, int>::iterator it = table->begin(); it != table->end(); it++) {
        lua_pushnumber(script, it->first);
        lua_pushnumber(script, it->second);
        lua_settable(script, -3);
    }
    
    delete table;
    
    return 1;
}

int script_map_out_vector(map<int, Vector*> *table) {
    lua_newtable(script);
    for (map<int, Vector*>::iterator it = table->begin(); it != table->end(); it++) {
        lua_pushnumber(script, it->first);
        
        swig_module_info *module = SWIG_GetModule(script);
        swig_type_info *type = SWIG_TypeQueryModule(module, module, "Vector *");
        SWIG_NewPointerObj(script, it->second, type, 0);
        lua_settable(script, -3);
        
        delete it->second;
    }
    
    delete table;
    
    return 1;
}
%}

%typemap(ret, noblock=1) map<int, int>*
{
    return script_map_out($1);
}

%typemap(ret, noblock=1) map<int, Vector *>*
{
    return script_map_out_vector($1);
}

void load_room(SDL_Surface *hot);

%rename(rebuild_waypoints) build_waypoints;
void build_waypoints();

%rename(get_neighbors) script_get_neighbors;
map<int, int> *script_get_neighbors(int node);

%rename(get_waypoint) script_get_waypoint;
Vector *script_get_waypoint(int waypointId);

%rename(get_closest_waypoint) script_get_closest_waypoint;
int script_get_closest_waypoint(Vector *pos);

%rename(enable_path) script_enable_path;
void script_enable_path(int path, bool enable = true);

%rename(is_walkable) script_is_walkable;
int script_is_walkable(SDL_Surface *bmp, Vector *pos);

%rename(is_pathable) script_is_pathable;
bool script_is_pathable(Vector *a, Vector *b);

%rename(which_hotspot) script_which_hotspot;
int script_which_hotspot(Vector *pixel);

%rename(get_walkspots) script_get_walkspots;
map<int, Vector*> *script_get_walkspots(SDL_Surface *bmp);
