#ifndef ADVENTURE_LUA_H
#define ADVENTURE_LUA_H

#include "adventure.h"

extern lua_State *script;

void init_script();
void boot_module();

#define lua_getregister(L, s)  lua_getfield(L, LUA_REGISTRYINDEX, s)
#define lua_setregister(L, s)  lua_setfield(L, LUA_REGISTRYINDEX, s)

#define lua_regtable(L, t, n, f) (lua_getglobal(L, t), lua_pushstring(L, n), lua_pushcfunction(L, f), lua_settable(L, -3), lua_pop(L, 1))

#define lua_setconstant(L, n, type, val) lua_getglobal(L, "readonly"); \
    lua_pushstring(L, "locks"); \
    lua_gettable(L, -2); \
    lua_pushstring(L, n); \
    lua_push##type(L, val); \
    lua_settable(L, -3); \
    lua_pop(L, 2);

#define CALL_ARGS(n)    { \
                            int _argi = 0; \
                            if (lua_gettop(L) != n
                            
#define CALL_TYPE(type) || !lua_is##type(L, ++_argi)

#define CALL_ERROR(msg) ) { \
                            lua_pushstring(L, msg); lua_error(L); \
                          } \
                        }

#endif
