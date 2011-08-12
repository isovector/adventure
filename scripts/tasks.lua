tasks = {current_tasks = {}, locks = {}, to_free = {}}
ticks = 0
 
function wait(ticks)
    coroutine.yield("wait", ticks)
end

function singleton(name)
    if (not table.contains(tasks.locks, name)) then
        table.insert(tasks.locks, name)
        coroutine.yield("free", name);
    else
        coroutine.yield()
    end
end
 
function tasks.begin(func)
    table.insert(tasks.current_tasks, {coroutine.create(func), 0})
end
 
function tasks.update(tick)
    ticks = ticks + tick
   
    for key, val in ipairs(tasks.current_tasks) do
        if ticks >= val[2] then
            local success, command, arg = coroutine.resume(val[1])

            if command == "wait" then
                val[2] = ticks + arg
            elseif command == "free" then
                table.insert(tasks.to_free, key, arg)
            else
                table.remove(tasks.current_tasks, key)
                table.remove(tasks.locks, key)
                table.remove(tasks.to_free, key)
            end
        end
    end
end