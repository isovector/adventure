#ifndef ADVENTURE_TASKS_H
#define ADVENTURE_TASKS_H

#include "adventure.h"

class ScriptTask {
public:
    ScriptTask(int taskId);
    virtual ~ScriptTask();
    
    void Initialize(lua_State* parent);
    void Update(float elapsed);

    bool IsInitialized() const { return mInitialized; }
    bool IsComplete() const { return mComplete; }
    lua_State* GetState() const { return mState; }

private:
    lua_State* mState;
    float mNextExecutionTimer;
    int  mTaskId;
    bool mComplete;
    bool mInitialized;
};

void task_start(int taskId);
void update_tasks(float elapsed);

extern list<ScriptTask> current_tasks;

#endif
