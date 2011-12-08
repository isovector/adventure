#ifndef ADVENTURE_LUA_H
#define ADVENTURE_LUA_H

#include "adventure.h"

extern lua_State *script;

void init_script();
void update_mouse();

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

#define NTHARG11(n, arg, ...) arg
#define NTHARG12(n, arg, ...) NTHARG2##n(n, __VA_ARGS__)
#define NTHARG13(n, arg, ...) NTHARG2##n(n, __VA_ARGS__)
#define NTHARG14(n, arg, ...) NTHARG2##n(n, __VA_ARGS__)
#define NTHARG15(n, arg, ...) NTHARG2##n(n, __VA_ARGS__)
#define NTHARG21(n, arg, ...) NTHARG3##n(n, __VA_ARGS__)
#define NTHARG22(n, arg, ...) arg
#define NTHARG23(n, arg, ...) NTHARG3##n(n, __VA_ARGS__)
#define NTHARG24(n, arg, ...) NTHARG3##n(n, __VA_ARGS__)
#define NTHARG25(n, arg, ...) NTHARG3##n(n, __VA_ARGS__)
#define NTHARG31(n, arg, ...) NTHARG4##n(n, __VA_ARGS__)
#define NTHARG32(n, arg, ...) NTHARG4##n(n, __VA_ARGS__)
#define NTHARG33(n, arg, ...) arg
#define NTHARG34(n, arg, ...) NTHARG4##n(n, __VA_ARGS__)
#define NTHARG35(n, arg, ...) NTHARG4##n(n, __VA_ARGS__)
#define NTHARG41(n, arg, ...) NTHARG5##n(n, __VA_ARGS__)
#define NTHARG42(n, arg, ...) NTHARG5##n(n, __VA_ARGS__)
#define NTHARG43(n, arg, ...) NTHARG5##n(n, __VA_ARGS__)
#define NTHARG44(n, arg, ...) arg
#define NTHARG45(n, arg, ...) NTHARG5##n(n, __VA_ARGS__)
#define NTHARG51(n, arg)
#define NTHARG52(n, arg)
#define NTHARG53(n, arg)
#define NTHARG54(n, arg)
#define NTHARG55(n, arg) arg

#define NTHARG(n, ...) NTHARG1##n(n, __VA_ARGS__)

#define LUA_CHECKARG1(type, ...) LUA_CHECKARG1_(type, __VA_ARGS__)
#define LUA_CHECKARG2(type, ...) LUA_CHECKARG2_(type, __VA_ARGS__)
#define LUA_CHECKARG3(type, ...) LUA_CHECKARG3_(type, __VA_ARGS__)
#define LUA_CHECKARG4(type, ...) LUA_CHECKARG4_(type, __VA_ARGS__)
#define LUA_CHECKARG5(type, ...) LUA_CHECKARG5_(type, __VA_ARGS__)

#define LUA_CHECKARG1_(type, ...) || !lua_is##type(L, 1)
#define LUA_CHECKARG2_(type, ...) || !lua_is##type(L, 2) LUA_CHECKARG1(NTHARG(1, __VA_ARGS__), __VA_ARGS__)
#define LUA_CHECKARG3_(type, ...) || !lua_is##type(L, 3) LUA_CHECKARG2(NTHARG(2, __VA_ARGS__), __VA_ARGS__)
#define LUA_CHECKARG4_(type, ...) || !lua_is##type(L, 4) LUA_CHECKARG3(NTHARG(3, __VA_ARGS__), __VA_ARGS__)
#define LUA_CHECKARG5_(type, ...) || !lua_is##type(L, 5) LUA_CHECKARG4(NTHARG(4, __VA_ARGS__), __VA_ARGS__)

#define LUA_GETARG1(type, ...) LUA_GETARG1_(type, __VA_ARGS__)
#define LUA_GETARG2(type, ...) LUA_GETARG2_(type, __VA_ARGS__)
#define LUA_GETARG3(type, ...) LUA_GETARG3_(type, __VA_ARGS__)
#define LUA_GETARG4(type, ...) LUA_GETARG4_(type, __VA_ARGS__)
#define LUA_GETARG5(type, ...) LUA_GETARG5_(type, __VA_ARGS__)

#define LUA_GETARG1_(type, ...) lua_to##type(script, 1)
#define LUA_GETARG2_(type, ...) LUA_GETARG1(NTHARG(1, __VA_ARGS__), __VA_ARGS__), lua_to##type(script, 2)
#define LUA_GETARG3_(type, ...) LUA_GETARG2(NTHARG(2, __VA_ARGS__), __VA_ARGS__), lua_to##type(script, 3)
#define LUA_GETARG4_(type, ...) LUA_GETARG3(NTHARG(3, __VA_ARGS__), __VA_ARGS__), lua_to##type(script, 4)
#define LUA_GETARG5_(type, ...) LUA_GETARG4(NTHARG(4, __VA_ARGS__), __VA_ARGS__), lua_to##type(script, 5)

#define LUA_WRAPVOID(name, narg, ...) \
    int script_##name (lua_State *L) { \
        if (lua_gettop(L) != narg LUA_CHECKARG##narg(NTHARG(narg, __VA_ARGS__), __VA_ARGS__)) { \
            lua_pushstring(L, #name " expects (" ")"); \
            lua_error(L);\
        } \
        name(LUA_GETARG##narg(NTHARG(narg, __VA_ARGS__), __VA_ARGS__));\
        return 0; \
    }

#define LUA_WRAP(name, narg, type, ...) \
    int script_##name (lua_State *L) { \
        if (lua_gettop(L) != narg LUA_CHECKARG##narg(NTHARG(narg, __VA_ARGS__), __VA_ARGS__)) { \
            lua_pushstring(L, #name " expects (" ")"); \
            lua_error(L);\
        } \
        lua_push##type(script, name(LUA_GETARG##narg(NTHARG(narg, __VA_ARGS__), __VA_ARGS__)));\
        return 1; \
    }

#define lua_call(state, __VA_ARGS__, rets) \
    if (lua_pcall(state, __VA_ARGS__, rets, 0) != 0) { \
        printf("LUA ERROR:\n%s\nat %s on line %d\n\n", lua_tostring(state, -1), __FILE__, __LINE__); \
    }


#ifndef DRAW_SPRITE_NORMAL
#define DRAW_SPRITE_NORMAL 0
#endif

#endif
