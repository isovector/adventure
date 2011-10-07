#ifndef ADVENTURE_LUA_H
#define ADVENTURE_LUA_H

#include "adventure.h"

#define LUA_PUSHPOS(x, y)   lua_newtable(script); \
                            lua_pushstring(script, "x"); \
                            lua_pushnumber(script, x); \
                            lua_settable(script, -3); \
                            lua_pushstring(script, "y"); \
                            lua_pushnumber(script, y); \
                            lua_settable(script, -3);

extern lua_State *script;

void init_script();
void actor_position(int*, int*);

#define lua_getregister(L, s)  lua_getfield(L, LUA_REGISTRYINDEX, s)
#define lua_setregister(L, s)  lua_setfield(L, LUA_REGISTRYINDEX, s)

#define lua_setconstant(L, n, type, val) lua_getglobal(L, "readonly"); \
    lua_pushstring(L, "locks"); \
    lua_gettable(L, -2); \
    lua_pushstring(L, n); \
    lua_push##type(L, val); \
    lua_settable(L, -3); \
    lua_pop(L, 2);

#define NTHARG11(n, arg, args ...) arg
#define NTHARG12(n, arg, args ...) NTHARG2##n(n, args)
#define NTHARG13(n, arg, args ...) NTHARG2##n(n, args)
#define NTHARG14(n, arg, args ...) NTHARG2##n(n, args)
#define NTHARG15(n, arg, args ...) NTHARG2##n(n, args)
#define NTHARG21(n, arg, args ...) NTHARG3##n(n, args)
#define NTHARG22(n, arg, args ...) arg
#define NTHARG23(n, arg, args ...) NTHARG3##n(n, args)
#define NTHARG24(n, arg, args ...) NTHARG3##n(n, args)
#define NTHARG25(n, arg, args ...) NTHARG3##n(n, args)
#define NTHARG31(n, arg, args ...) NTHARG4##n(n, args)
#define NTHARG32(n, arg, args ...) NTHARG4##n(n, args)
#define NTHARG33(n, arg, args ...) arg
#define NTHARG34(n, arg, args ...) NTHARG4##n(n, args)
#define NTHARG35(n, arg, args ...) NTHARG4##n(n, args)
#define NTHARG41(n, arg, args ...) NTHARG5##n(n, args)
#define NTHARG42(n, arg, args ...) NTHARG5##n(n, args)
#define NTHARG43(n, arg, args ...) NTHARG5##n(n, args)
#define NTHARG44(n, arg, args ...) arg
#define NTHARG45(n, arg, args ...) NTHARG5##n(n, args)
#define NTHARG51(n, arg)
#define NTHARG52(n, arg)
#define NTHARG53(n, arg)
#define NTHARG54(n, arg)
#define NTHARG55(n, arg) arg

#define NTHARG(n, args ...) NTHARG1##n(n, args)

#define LUA_CHECKARG1(type, args ...) LUA_CHECKARG1_(type, args)
#define LUA_CHECKARG2(type, args ...) LUA_CHECKARG2_(type, args)
#define LUA_CHECKARG3(type, args ...) LUA_CHECKARG3_(type, args)
#define LUA_CHECKARG4(type, args ...) LUA_CHECKARG4_(type, args)
#define LUA_CHECKARG5(type, args ...) LUA_CHECKARG5_(type, args)

#define LUA_CHECKARG1_(type, args ...) || !lua_is##type(L, 1)
#define LUA_CHECKARG2_(type, args ...) || !lua_is##type(L, 2) LUA_CHECKARG1(NTHARG(1, args), args)
#define LUA_CHECKARG3_(type, args ...) || !lua_is##type(L, 3) LUA_CHECKARG2(NTHARG(2, args), args)
#define LUA_CHECKARG4_(type, args ...) || !lua_is##type(L, 4) LUA_CHECKARG3(NTHARG(3, args), args)
#define LUA_CHECKARG5_(type, args ...) || !lua_is##type(L, 5) LUA_CHECKARG4(NTHARG(4, args), args)

#define LUA_GETARG1(type, args ...) LUA_GETARG1_(type, args)
#define LUA_GETARG2(type, args ...) LUA_GETARG2_(type, args)
#define LUA_GETARG3(type, args ...) LUA_GETARG3_(type, args)
#define LUA_GETARG4(type, args ...) LUA_GETARG4_(type, args)
#define LUA_GETARG5(type, args ...) LUA_GETARG5_(type, args)

#define LUA_GETARG1_(type, args ...) lua_to##type(script, 1)
#define LUA_GETARG2_(type, args ...) LUA_GETARG1(NTHARG(1, args), args), lua_to##type(script, 2)
#define LUA_GETARG3_(type, args ...) LUA_GETARG2(NTHARG(2, args), args), lua_to##type(script, 3)
#define LUA_GETARG4_(type, args ...) LUA_GETARG3(NTHARG(3, args), args), lua_to##type(script, 4)
#define LUA_GETARG5_(type, args ...) LUA_GETARG4(NTHARG(4, args), args), lua_to##type(script, 5)

#define LUA_WRAP(name, narg, type, args ...) \
    int script_##name (lua_State *L) { \
        if (lua_gettop(L) != narg LUA_CHECKARG##narg(NTHARG(narg, args), args)) { \
            lua_pushstring(L, #name " expects (" ")"); \
            lua_error(L);\
        } \
        lua_push##type(script, name(LUA_GETARG##narg(NTHARG(narg, args), args)));\
        return 1; \
    }

#define lua_call(state, args, rets) \
    if (lua_pcall(state, args, rets, 0) != 0) { \
        printf("LUA ERROR:\n%s\nat %s on line %d\n\n", lua_tostring(state, -1), __FILE__, __LINE__); \
    }


#ifndef DRAW_SPRITE_NORMAL
#define DRAW_SPRITE_NORMAL 0
#endif

#endif
