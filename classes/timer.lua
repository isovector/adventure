require "classes/class"

-- timer class appears to be borked
newclass("Timer", function(duration, callback)
        local timer = { alive = true }
        
        local time
        local function timerCallback()
            while timer.alive do
                time = duration
                while time > 0 do
                    time = time - coroutine.yield()
                end
                
                callback()
            end
        end
        
        local routine = MOAICoroutine.new()
        routine:run(timerCallback)
        
        timer.routine = routine
        return timer
    end
)

function Timer:stop()
    self.alive = false
    self.routine = nil
end
