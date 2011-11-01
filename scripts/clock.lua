clock = { 
    time = 0,
    timespeed = 0,
    hours = 24,
    day = 0
}

function clock.set_speed(gamemins, seconds)
    clock.timespeed = gamemins / (framerate * seconds * 100)
end

function clock.tick()
    local hour = math.ipart(clock.time)
    clock.time = clock.time + clock.timespeed
    
    if math.ipart(clock.time) ~= hour then
        do_callback("event", "__clock", "hour")
    end
    
    if math.ipart(clock.time) == clock.hours then
        clock.time = 0
        clock.day = clock.day + 1
        do_callback("event", "__clock", "day")
    end
end

function clock.get_time()
    local hour = math.ipart(clock.time)
    local minute = math.ipart(math.fpart(clock.time) * 100)
    return hour .. ":" .. minute
end