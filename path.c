#include "adventure.h"

POINT *waypoints[MAX_WAYPOINTS];
unsigned int waypoint_connections[MAX_WAYPOINTS] = {0};
int enabled_paths[256] = {0};

int waypoint_count = 0;

void connect_waypoints(int a, int b) {
    waypoint_connections[a] |= 1 << b;
    waypoint_connections[b] |= 1 << a;
}

int is_pathable(int x1, int y1, int x2, int y2) {
    float x = x1,
          y = y1;
    float dx = x2 - x1, 
          dy = y2 - y1;
    float dist = sqrt(dx * dx + dy * dy);
    
    dx /= dist;
    dy /= dist;

    for (int i = 0; i < (int)dist; i++) {
        x += dx;
        y += dy;
        if (!is_walkable((int)x, (int)y)) {
            return 0;
        }
    }
    
    return 1;
}

void build_waypoints() {
    for (int i = 0; i < waypoint_count; i++) {
        free(waypoints[i]);
        waypoint_connections[i] = 0;
    }
    
    waypoint_count = 0;
    
    for (int y = 0; y < SCREEN_HEIGHT; y++)
    for (int x = 0; x < SCREEN_WIDTH; x++)
        if (getpixel(room_hot, x, y) == 255) {
            waypoints[waypoint_count] = malloc(sizeof(POINT));
            waypoints[waypoint_count]->x = x;
            waypoints[waypoint_count++]->y = y;
        }
        
    for (int a = 0; a < waypoint_count; a++)
    for (int b = a + 1; b < waypoint_count; b++) {
        POINT pa = *waypoints[a], pb = *waypoints[b];
        if (is_pathable(pa.x, pa.y, pb.x, pb.y))
            connect_waypoints(a, b);
    }
}

int get_neighbors(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_isnumber(L, 1)) {
        lua_pushstring(L, "get_neighbors expects (int)");
        lua_error(L);
    }
    
    int connection = waypoint_connections[(int)lua_tonumber(L, 1)];
    lua_newtable(L);
    
    int j = 1;
    for (int i = 0; i < MAX_WAYPOINTS; i++)
        if (connection & (1 << i)) {
            lua_pushnumber(L, j++);
            lua_pushnumber(L, i);
            lua_settable(L, -3);
        }
        
    return 1;
}

int get_waypoint(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_isnumber(L, 1)) {
        lua_pushstring(L, "get_waypoint expects (int)");
        lua_error(L);
    }
    
    POINT *waypoint = waypoints[(int)lua_tonumber(L, 1)];
    
    lua_newtable(L);
    lua_pushstring(L, "x");
    lua_pushnumber(L, waypoint->x);
    lua_settable(L, -3);
    lua_pushstring(L, "y");
    lua_pushnumber(L, waypoint->y);
    lua_settable(L, -3);
    
    return 1;
}


int get_closest_waypoint(lua_State *L) {
    if (lua_gettop(L) != 1 || !lua_istable(L, 1)) {
        lua_pushstring(L, "get_closest_waypoint expects (table)");
        lua_error(L);
    }
    
	lua_pushstring(L, "x");
	lua_gettable(L, -2);
	int x = (int)lua_tonumber(L, -1);
	lua_pop(L, 1);
	lua_pushstring(L, "y");
	lua_gettable(L, -2);
	int y = (int)lua_tonumber(L, -1);
	lua_pop(L, 2);
    
    lua_pushnumber(L, closest_waypoint(x, y));
    return 1;
}

int lua_enable_path(lua_State *L) {
    if (lua_gettop(L) != 2 || !lua_isnumber(L, 1) || !lua_isboolean(L, 2)) {
        lua_pushstring(L, "enable_path expects (int, bool)");
        lua_error(L);
    }
    
    enabled_paths[(int)lua_tonumber(L, 1)] = lua_toboolean(L, 2);
    build_waypoints();
    
    return 0;
}

int is_walkable(int x, int y) {
	return enabled_paths[(getpixel(room_hot, x, y) & (255 << 8)) >> 8] || getpixel(room_hot, x, y) == 255;
}

int closest_waypoint(int x, int y) {
    int dist = 9999999;
    int winner = 0;
    
    for (int i = 0; i < waypoint_count; i++) {
		int tx = waypoints[i]->x - x;
		int ty = waypoints[i]->y - y;
        int dif = sqrt(tx * tx + ty * ty);
        if (dif < dist) {
            dist = dif;
            winner = i;
        }
    }
	
    return winner;
}

void register_path() {
    lua_register(script, "get_neighbors", &get_neighbors);
    lua_register(script, "get_waypoint", &get_waypoint);
    lua_register(script, "get_closest_waypoint", &get_closest_waypoint);
    lua_register(script, "enable_path", &lua_enable_path);
}