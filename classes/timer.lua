require "classes/class"

newclass("Timer", function(time, callback)
        local timer = MOAITimer.new()
        timer:setMode(MOAITimer.LOOP)
        timer:setListener(MOAITimer.EVENT_TIMER_LOOP, callback)
        timer:setSpan(time)
        timer:start()
        
        return { timer = timer }
    end
)

function Timer:stop()
    self.timer:stop()
    self.timer = nil
end