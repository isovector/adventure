#include "adventure.h"

map<string, set<size_t> > breakpoints;
map<lua_State*, ScriptTask*> task_map;
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
    ScriptTask *task = task_map[L];
    task->Hook(ar);
}

void tasks_get_debug() {
    static time_t last_mtime = 0;
    fstream file;
    size_t line;
    string fname;
    
    struct stat mtstat;
    if (stat("adventure.dbg", &mtstat) == -1)
        return;
    
    if (mtstat.st_mtime <= last_mtime)
        return;
    
    last_mtime = mtstat.st_mtime;
    
    file.open("adventure.dbg", fstream::in);
    if (file.fail())
        return;
    
    breakpoints.clear();
    while (!file.eof()) {
        file >> line;
        file >> fname;
        
        if (!breakpoints.count(fname))
            breakpoints[fname] = set<size_t>();
        
        breakpoints[fname].insert(line);
    }
    
    file.close();
}


ScriptTask::ScriptTask(int taskId) :
    mNextExecutionTimer(0.0f),
    mTaskId(taskId),
    mComplete(false),
    mInitialized(false),
    mLinesExecuted(0)
{ }

void ScriptTask::Initialize(lua_State* parent) {
    if (parent == NULL) {
        mState = lua_open();
        
        luaL_openlibs(mState);
        luaopen_geometry(mState);
        luaopen_drawing(mState);
        luaopen_pathfinding(mState);
        luaopen_tasks(mState);
        
        lua_atpanic(mState, script_panic);
    }
    else {
        mState = lua_newthread(parent);
        
        lua_getglobal(mState, "tasks");
        lua_pushstring(mState, "jobs");
        lua_gettable(mState, -2);
        lua_pushnumber(mState, mTaskId);
        lua_gettable(mState, -2);
        
        SetHook(true);
    }
    
    task_map[mState] = this;
    
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

void ScriptTask::Hook(lua_Debug *debug) {
    lua_getinfo(mState, "Sl", debug);
    if (breakpoints.count(debug->source) && breakpoints[debug->source].count(debug->currentline))
        cerr << "BREAKPOINT at " << (debug->source + 1) << " on line #" << debug->currentline << endl;
    
    if (++mLinesExecuted == MAX_EXECUTION) {
        lua_pushstring(mState, "Infinite loop detected - killing task.");
        lua_error(mState);
        mComplete = true;
    }
}

void ScriptTask::SetHook(bool enabled) {
    lua_sethook(mState, lua_hook, enabled ? LUA_MASKLINE : 0, 0);
}

void ScriptTask::ResetExecutedLines() {
    mLinesExecuted = 0;
}

void ScriptTask::Continue() {
    int top = lua_gettop(mState);
    
    ResetExecutedLines();
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
            cerr << "ERROR: " << lua_tostring(mState, -1) << endl;
            mComplete = true;
            break;
    }
}
