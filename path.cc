#include "adventure.h"

Vector *waypoints[MAX_WAYPOINTS];
unsigned int waypoint_connections[MAX_WAYPOINTS] = {0};
int enabled_paths[256] = {0};
int waypoint_count = 0;

void connect_waypoints(int a, int b) {
    waypoint_connections[a] |= 1 << b;
    waypoint_connections[b] |= 1 << a;
}

bool is_pathable(const Vector &start, const Vector &end) {
    Vector dd = end - start;
    float dist = dd.Length();
    Vector trace = start;
    dd.Normalize();

    for (int i = 0; i < (int)dist; i++) {
        trace += dd;
        
        if (!is_walkable(trace))
            return false;
    }
    
    return true;
}

void build_waypoints() {
    int i, x, y, a, b;

    for (i = 0; i < waypoint_count; i++) {
        delete waypoints[i];
        waypoint_connections[i] = 0;
    }
    
    waypoint_count = 0;
    
    for (y = 0; y < SCREEN_HEIGHT; y++)
    for (x = 0; x < SCREEN_WIDTH; x++)
        if (getpixel(room_hot, x, y) == 255) {
            waypoints[waypoint_count++] = new Vector(x, y);
        }
    
    for (a = 0; a < waypoint_count; a++)
    for (b = a + 1; b < waypoint_count; b++) {
        Vector pa = *waypoints[a], pb = *waypoints[b];
        if (is_pathable(pa, pb))
            connect_waypoints(a, b);
    }
}

bool is_walkable(const Vector &pos) {
    int x = pos.x, y = pos.y;

    return enabled_paths[(getpixel(room_hot, x, y) & (255 << 8)) >> 8] || getpixel(room_hot, x, y) == 255;
}

int closest_waypoint(const Vector &pos) {
    int x = pos.x, y = pos.y;
    
    int dist = 9999999, winner = 0;
    int i, tx, ty, dif;
    
    for (i = 0; i < waypoint_count; i++) {
        tx = waypoints[i]->x - x;
        ty = waypoints[i]->y - y;
        dif = /*sqrt(*/tx * tx + ty * ty/*)*/;
        if (dif < dist && is_pathable(pos, Vector(waypoints[i]->x, waypoints[i]->y))) {
            dist = dif;
            winner = i;
        }
    }
    
    return winner;
}

map<int, int> *script_get_neighbors(int node) {
    int i, j = 1, connection;
    map<int, int> *table = new map<int, int>();
        
    connection = waypoint_connections[node];
    
    for (i = 0; i < MAX_WAYPOINTS; i++)
        if (connection & (1 << i))
            (*table)[j++] = i;
        
    return table;
}

Vector *script_get_waypoint(int waypointId) {
    Vector defaultspot, *waypoint;

    defaultspot.x = 0;
    defaultspot.y = 0;
    
    waypoint = waypoints[waypointId];
    if (!waypoint)
        waypoint = &defaultspot;
    
    return new Vector(waypoint->x, waypoint->y);
}

int script_get_closest_waypoint(Vector *pos) {
    return closest_waypoint(*pos);
}

void script_enable_path(int path, bool enable) {
    enabled_paths[path] = enable;
}

int script_is_walkable(SDL_Surface *bmp, Vector *pos) {
    int x = pos->x, y = pos->y;
    int pixel = getpixel(bmp, x, y);
    
    if (pixel == 255)
        return 255;
    return (pixel & (255 << 8)) >> 8;
}

bool script_is_pathable(Vector *a, Vector *b) {
    return is_pathable(*a, *b);
}

int script_which_hotspot(Vector *pixel) {
    int x = pixel->x, y = pixel->y;
        
    return (getpixel(room_hot, x, y) & (255 << 16)) >> 16;
}

map<int, Vector*> *script_get_walkspots(SDL_Surface *bmp) {
    int color = 0, x, y;
    map<int, Vector*> *results = new map<int, Vector*>();
        
    for (y = 0; y < SCREEN_HEIGHT; y++)
    for (x = 0; x < SCREEN_WIDTH; x++)
        if ((color = getpixel(bmp, x, y)) && color < 255)
            (*results)[color] = new Vector(x, y);
        
    return results;
}
