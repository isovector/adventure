#include "adventure.h"

list<ScriptTask> current_tasks;

void task_start(int taskId) {
    ScriptTask task(taskId);
    current_tasks.push_back(task);
}

void update_tasks(float elapsed) {
    for (list<ScriptTask>::iterator it = current_tasks.begin(); it != current_tasks.end(); ++it) {
        ScriptTask &task = *it;
        
        if (!task.IsInitialized())
            task.Initialize(script);
        
        task.Update(elapsed);
        
        if (task.IsComplete()) {
            it = current_tasks.erase(it);
            --it;
        }
    }
}

ScriptTask::ScriptTask(int taskId) :
    mNextExecutionTimer(0.0f),
    mTaskId(taskId),
    mComplete(false),
    mInitialized(false) { }

void ScriptTask::Initialize(lua_State* parent) {
    mState = lua_newthread(parent);

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
    
    if (mNextExecutionTimer <= 0.0f) {
        switch (lua_resume(mState, 0)) {
            case LUA_YIELD:
                mNextExecutionTimer = lua_tonumber(mState, -1);
                break;
            
            case 0:
                mComplete = true;
                break;
            
            default:
                cout << "ERROR, DUDE" << endl;
                // debug me :(
                break;
        }
    }
}
