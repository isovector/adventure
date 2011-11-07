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

function tasks.begin(chain, continue, chain_call)
    if not chain_call then
        tasks.log = "starting task " .. tostring(table.car(chain))
    end

    table.insert(tasks.current_tasks, {
        task = coroutine.create(table.car(chain)),
        time = 0,
        continue = continue,
        after = table.cdr(chain)
    })
end

function tasks.update()
    local elapsed = 1 / framerate
    tick = elapsed * 1000

    ticks = ticks + tick

    for key, task in ipairs(tasks.current_tasks) do
        if ticks >= task.time then
            local success, command, arg = coroutine.resume(task.task)

            if command == "wait" then
                task.time = ticks + arg
            elseif command == "free" then
                table.insert(tasks.to_free, key, arg)
            else
                table.remove(tasks.current_tasks, key)
                table.remove(tasks.locks, key)
                table.remove(tasks.to_free, key)

                if task.after and command == task.continue then
                    tasks.begin(task.after, task.continue, true)
                end
            end
        end
    end
end