#include "adventure.h"

list<ScriptTask> current_tasks;

void task_start(int taskId) {
    ScriptTask task(taskId);
    current_tasks.push_back(task);
}

void task_raise_signal(const char *signal) {
    for (list<ScriptTask>::iterator it = current_tasks.begin(); it != current_tasks.end(); ++it) {
        ScriptTask &task = *it;
        task.Raise(signal);
    }
}

void tasks_update(float elapsed) {
    for (list<ScriptTask>::iterator it = current_tasks.begin(); it != current_tasks.end(); ++it) {
        ScriptTask &task = *it;
        
        if (!task.IsInitialized())
            task.Initialize(script);
        
        if (!task.IsComplete())
            task.Update(elapsed);
        
        if (task.IsComplete()) {
            it = current_tasks.erase(it);
            --it;
        }
    }
}

void lua_hook(lua_State *L, lua_Debug *ar) {
    ScriptTask *task = (ScriptTask*)lua_statedata(L);
    task->Hook();
}

ScriptTask::ScriptTask(int taskId) :
    mNextExecutionTimer(0.0f),
    mTaskId(taskId),
    mComplete(false),
    mInitialized(false),
    mLinesExecuted(0)
{ }

void ScriptTask::Initialize(lua_State* parent) {
    mState = lua_newthread(parent);
    lua_statedata(mState) = (void*)this;
    
    lua_sethook(mState, lua_hook, LUA_MASKLINE, 0);
    
    lua_getglobal(mState, "tasks");
    lua_pushstring(mState, "jobs");
    lua_gettable(mState, -2);
    lua_pushnumber(mState, mTaskId);
    lua_gettable(mState, -2);
    
    mInitialized = true;
}

ScriptTask::~ScriptTask() {
}

void ScriptTask::Update(float elapsed) {
    mNextExecutionTimer -= elapsed;
    
    if (!mInitialized)
        return;
    
    if (mNextExecutionTimer <= 0.0f && mNextExecutionSignal == "")
        Continue();
}

void ScriptTask::Raise(string signal) {
    if (mNextExecutionSignal == signal) {
        mNextExecutionSignal = "";
        mNextExecutionTimer = 0.0f;
    }
}

void ScriptTask::Hook() {
    if (++mLinesExecuted == MAX_EXECUTION) {
        lua_pushstring(mState, "Infinite loop detected - killing task.");
        lua_error(mState);
        mComplete = true;
    }
}

void ScriptTask::Continue() {
    int top = lua_gettop(mState);
    
    switch (lua_resume(mState, 0)) {
        case LUA_YIELD:
            if (lua_type(mState, -1) == LUA_TNUMBER)
                mNextExecutionTimer = lua_tonumber(mState, -1);
            else if (lua_type(mState, -1) == LUA_TSTRING)
                mNextExecutionSignal = lua_tostring(mState, -1);
            break;
        
        case 0:
            mComplete = true;
            break;
        
        default:
            cout << "ERROR: " << lua_tostring(mState, -1) << endl;
            mComplete = true;
            break;
    }
}