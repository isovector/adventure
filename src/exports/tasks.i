%module tasks
%{
#include "script.h"
%}

%rename(raw_start) task_start;
void task_start(int taskId);

%rename(raise) task_raise_signal;
void task_raise_signal(const char *signal);

%native(sleep) int native_sleep(lua_State *L);

%{
int native_sleep(lua_State *L) {
    if (lua_gettop(L) != 1) {
        lua_pushstring(L, "tasks.sleep() expects exactly one parameter");
        lua_error(L);
    }

    return lua_yield(L, 1);
}
%}
