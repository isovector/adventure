--- Provides an interruptable timer with customizable delta callbacks.

mrequire "classes/class"

--- The Timer class.
-- Constructor signature is (duration, rep, callback, deltacallback).
-- @newclass Timer
newclass("Timer", 
    function(duration, rep, callback, deltacallback)
        local timer = { alive = true }
        
        local time
        local function timerCallback()
            repeat
                time = duration
                while time > 0 and timer.alive do
                    time = time - coroutine.yield()
                    
                    if deltacallback then
                        deltacallback(timer, time)
                    end
                end
                
                if timer.alive then
                    callback(timer)
                end
            until not (rep and timer.alive)
        end
        
        local routine = MOAICoroutine.new()
        routine:run(timerCallback)
        
        timer.routine = routine
        return timer
    end
)

--- Stops a running timer.
function Timer:stop()
    self.alive = false
    self.routine = nil
end
