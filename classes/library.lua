function sleep(time)
    local timer = MOAITimer.new()
    timer:setSpan(delay)
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
