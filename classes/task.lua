--- Provides asynchronous task functionality.

mrequire "classes/class"

--- The static Task class.
-- @newclass Task
newclass("Task", false)

--- Blocks the currently running task.
-- @param time The time to block for in seconds
function Task.sleep(time)
    local timer = MOAITimer.new()
    timer:setSpan(time)
    timer:setListener(
        MOAITimer.EVENT_TIMER_LOOP,
        function()
            timer:stop()
            timer = nil
        end
    )

    timer:start()
    MOAIThread.blockOnAction(timer)
end

--- Runs a function asynchronously
-- @param callback
-- @param ...
function Task.start(callback, ...)
    local thread = MOAIThread.new()
    thread:run(callback, ...)
end
