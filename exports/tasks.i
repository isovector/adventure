%module tasks
%{
#include "adventure.h"
%}

%rename(raw_start) task_start;
void task_start(int taskId);

%native(sleep) int native_sleep(lua_State *L);

%{
int native_sleep(lua_State *L) {
    return lua_yield(L, lua_gettop(L));
}
%}
