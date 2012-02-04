#include "adventure.h"
#include "libs/poly2tri/poly2tri.h"
using namespace p2t;

POINT *waypoints[MAX_WAYPOINTS];
unsigned int waypoint_connections[MAX_WAYPOINTS] = {0};
int enabled_paths[256] = {0};

int waypoint_count = 0;

void lua_vector(lua_State *L, int x, int y) {
    lua_getglobal(L, "vec");
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    lua_call(L, 2, 1);
}

void extract_vector(lua_State *L, int pos, int *x, int *y) {
    lua_pushvalue(L, pos);
    
    lua_pushstring(L, "x");
    lua_gettable(L, -2);
    *x = (int)lua_tonumber(L, -1);
    lua_pop(L, 1);
    
    lua_pushstring(L, "y");
    lua_gettable(L, -2);
    *y = (int)lua_tonumber(L, -1);
    lua_pop(L, 2);
}

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
    int i;
    
    dx /= dist;
    dy /= dist;

    for (i = 0; i < (int)dist; i++) {
        x += dx;
        y += dy;
        
        if (!is_walkable((int)x, (int)y))
            return 0;
    }
    
    return 1;
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
            waypoints[waypoint_count] = new POINT;
            waypoints[waypoint_count]->x = x;
            waypoints[waypoint_count++]->y = y;
        }
    
    for (a = 0; a < waypoint_count; a++)
    for (b = a + 1; b < waypoint_count; b++) {
        POINT pa = *waypoints[a], pb = *waypoints[b];
        if (is_pathable(pa.x, pa.y, pb.x, pb.y))
            connect_waypoints(a, b);
    }
}

int script_get_neighbors(lua_State *L) {
    int i, j = 1, connection;
    
    if (lua_gettop(L) != 1 || !lua_isnumber(L, 1)) {
        lua_pushstring(L, "get_neighbors expects (int)");
        lua_error(L);
    }
    
    connection = waypoint_connections[(int)lua_tonumber(L, 1)];
    lua_newtable(L);
    
    for (i = 0; i < MAX_WAYPOINTS; i++)
        if (connection & (1 << i)) {
            lua_pushnumber(L, j++);
            lua_pushnumber(L, i);
            lua_settable(L, -3);
        }
        
    return 1;
}

int script_get_waypoint(lua_State *L) {
    POINT defaultspot, *waypoint;
    
    CALL_ARGS(1)
    CALL_TYPE(number)
    CALL_ERROR("get_waypoint expects (int)")
    
    defaultspot.x = 0;
    defaultspot.y = 0;
    
    waypoint = waypoints[(int)lua_tonumber(L, 1)];
    if (!waypoint)
        waypoint = &defaultspot;
    
    lua_vector(L, waypoint->x, waypoint->y);
        
    return 1;
}

int script_get_closest_waypoint(lua_State *L) {
    int x, y;
    
    CALL_ARGS(1)
    CALL_TYPE(table)
    CALL_ERROR("get_closest_waypoint expects (table)")
        
    extract_vector(L, -1, &x, &y);
    lua_pushnumber(L, closest_waypoint(x, y));
    
    return 1;
}

int script_enable_path(lua_State *L) {
    int n, b;
    
    // TODO(sandy): we need a way to have optional args
    if ((lua_gettop(L) == 1 && !lua_isnumber(L, 1)) ||
        (lua_gettop(L) >= 2 && (!lua_isnumber(L, 1) || !lua_isboolean(L, 2)))) {
        lua_pushstring(L, "enable_path expects (int, [bool])");
        lua_error(L);
    }
    
    n = lua_tonumber(L, 1);
    b = lua_gettop(L) == 2 ? lua_toboolean(L, 2) : 1;
    
    enabled_paths[n] = b;
        
    return 0;
}

int script_rebuild_waypoints(lua_State *L) {
    CALL_ARGS(0)
    CALL_ERROR("rebuild_waypoints expects ()")
    
    build_waypoints();
    
    return 0;
}

int is_walkable(int x, int y) {    
    return enabled_paths[(getpixel(room_hot, x, y) & (255 << 8)) >> 8] || getpixel(room_hot, x, y) == 255;
}

int script_is_walkable(lua_State *L) {
    BITMAP *bmp;
    int x, y, pixel;
    
    CALL_ARGS(2)
    CALL_TYPE(userdata)
    CALL_TYPE(table)
    CALL_ERROR("is_walkable expects (bitmap, vector)")
    
    bmp = *(BITMAP**)lua_touserdata(L, 1);
    
    extract_vector(L, -1, &x, &y);
    pixel = getpixel(bmp, x, y);
    
    if (pixel == 255)
        lua_pushnumber(L, 255);
    else
        lua_pushnumber(L, (pixel & (255 << 8)) >> 8);
    
    return 1;
}

int script_is_pathable(lua_State *L) {
    int x1, x2, y1, y2;
    
    CALL_ARGS(2)
    CALL_TYPE(table)
    CALL_TYPE(table)
    CALL_ERROR("is_pathable expects (vector, vector)")
    
    extract_vector(L, 1, &x1, &y1);
    extract_vector(L, 2, &x2, &y2);
    
    lua_pushboolean(L, is_pathable(x1, y1, x2, y2));
    
    return 1;
}

int closest_waypoint(int x, int y) {
    int dist = 9999999, winner = 0;
    int i, tx, ty, dif;
    
    for (i = 0; i < waypoint_count; i++) {
        tx = waypoints[i]->x - x;
        ty = waypoints[i]->y - y;
        dif = sqrt(tx * tx + ty * ty);
        if (dif < dist && is_pathable(x, y, waypoints[i]->x, waypoints[i]->y)) {
            dist = dif;
            winner = i;
        }
    }
    
    return winner;
}

int script_get_walkspots(lua_State *L) {
    int color = 0, x, y;
    BITMAP *bmp;
    
    CALL_ARGS(1)
    CALL_TYPE(userdata)
    CALL_ERROR("get walkspots expects (bitmap)")
    
    bmp = *(BITMAP**)lua_touserdata(L, 1);
    lua_newtable(L);
    
    for (y = 0; y < SCREEN_HEIGHT; y++)
    for (x = 0; x < SCREEN_WIDTH; x++)
        if ((color = getpixel(bmp, x, y)) && color < 255) {
            lua_pushnumber(L, color);
            lua_vector(L, x, y);
            lua_settable(L, -3);
        }
        
    return 1;
}

int script_get_navmesh(lua_State *L) {
    vector<Point*> vertices;
    vector<Triangle*> triangles;
    vector<Point*>::iterator it;
    Triangle *t;
    Point *p;
    CDT* cdt;
    int x, y, n, i, j;
    
    CALL_ARGS(1)
    CALL_TYPE(table)
    CALL_ERROR("get_navmesh expects (vector[])")
    
    lua_getglobal(L, "table");
    lua_pushstring(L, "getn");
    lua_gettable(L, -2);
    lua_pushvalue(L, 1);
    lua_call(L, 1, 1);
    n = lua_tonumber(L, -1);
    lua_pop(L, 2);
    
    lua_pushvalue(L, 1);
    
    for (i = 1; i <= n; i++) {
        lua_pushnumber(L, i);
        lua_gettable(L, -2);
        extract_vector(L, -1, &x, &y);
        lua_pop(L, 1);
        
        vertices.push_back(new Point(x, y));
    }
    
    cdt = new CDT(vertices);
    cdt->Triangulate();
    triangles = cdt->GetTriangles();
    
    lua_newtable(L);
    for (i = 0; i < triangles.size(); i++) {
        lua_pushnumber(L, i + 1);
        lua_newtable(L);
        
        t = triangles[i];
        for (j = 0; j < 3; j++) {
            p = t->GetPoint(j);
            
            lua_pushnumber(L, j + 1);
            lua_vector(L, p->x, p->y);
            lua_settable(L, -3);
        }
        
        lua_settable(L, -3);
    }
    
    delete cdt;
    for (it = vertices.begin(); it != vertices.end(); it++) {
        delete (*it);
    }
    
    return 1;
}

void register_path() {
    lua_register(script, "get_neighbors", &script_get_neighbors);
    lua_register(script, "get_waypoint", &script_get_waypoint);
    lua_register(script, "get_walkspots", &script_get_walkspots);
    lua_register(script, "get_closest_waypoint", &script_get_closest_waypoint);
    lua_register(script, "enable_path", &script_enable_path);
    lua_register(script, "rebuild_waypoints", &script_rebuild_waypoints);
    lua_register(script, "is_walkable", &script_is_walkable);
    lua_register(script, "is_pathable", &script_is_pathable);
    lua_register(script, "get_navmesh", &script_get_navmesh);
}
