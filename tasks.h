#ifndef ADVENTURE_TASKS_H
#define ADVENTURE_TASKS_H

#include "adventure.h"

class ScriptTask {
public:
    ScriptTask(int taskId);
    virtual ~ScriptTask();
    
    void Initialize(lua_State* parent);
    void Update(float elapsed);
    void Raise(string signal);

    bool IsInitialized() const { return mInitialized; }
    bool IsComplete() const { return mComplete; }
    lua_State* GetState() const { return mState; }

private:
    void Continue();

    lua_State* mState;

    string mNextExecutionSignal;
    float  mNextExecutionTimer;
    int  mTaskId;
    bool mComplete;
    bool mInitialized;
};

void task_start(int taskId);
void task_raise_signal(const char *signal);
void tasks_update(float elapsed);

extern list<ScriptTask> current_tasks;

#endif
