actors = {
    jack = {
        name = "Gomez",
        pos = {x = 600, y = 300}, 
        color = 255, 
        speed = 150, 
        goal = nil, 
        goals = {},
        inventory = {},
        flipped = 0,
        aplay = animation.start(animations.gomez, "stand")
    }
}
player = actors.jack

framerate = 60 -- this should be "magic" from the engine

function tick()
    local elapsed = 1 / framerate
    tasks.update(elapsed * 1000)
   
    for name, actor in pairs(actors) do
        animation.play(actor.aplay, elapsed)
    
        if actor.goal then
            animation.switch(actor.aplay, "walk")
        
            local speed = actor.speed * elapsed
            local dif = vector.diff(actor.pos, actor.goal)
            if vector.length(dif) > speed then
                local dir = vector.normal(dif)
                
                if dir.x < 0 then 
                    actor.flipped = 1
                else
                    actor.flipped = 0
                end
                
                actor.pos.x = actor.pos.x + dir.x * speed
                actor.pos.y = actor.pos.y + dir.y * speed
            else
                actor.pos = actor.goal
                actor.goal = nil
                
                if actor.goals[1] then
                    actor.goal = actor.goals[1]
                    table.remove(actor.goals, 1)
                end
            end
        else
            animation.switch(actor.aplay, "stand")
        end
    end
end

function distance(from, to)
    return 1
end

function do_pathfinding(from, to)
    local function add_path(old, new, cost)
        return { cost = cost, location = new, previous = old }
    end

    local closed = { }
    local open = { { 0, add_path(nil, from, 0) } }
    
    while open do
        local continue = true
        repeat
            local path = pqueue.dequeue(open)
            if table.contains(closed, path.location) then continue = true; break end
            if to == path.location then return path end
            table.insert(closed, path.location)
            
            for key, val in ipairs(get_neighbors(path.location)) do
                local dist = distance(path.location, get_waypoint(val))
                pqueue.enqueue(open, -(path.cost + dist), add_path(path, val, path.cost + dist))
            end
        until true
        if not continue then break end
    end
end

function walk(actor, to, y)
    if y then to = {x = to, y = y} end

    actor.goal = get_waypoint(get_closest_waypoint(actor.pos))
    actor.goals = unwrap_path(do_pathfinding(get_closest_waypoint(actor.pos), get_closest_waypoint(to)))
    table.insert(actor.goals, to)
end

function say(who, what, time)
    if not time then
        time = #what * 75
    end
    print(who .. "> " .. what)
    wait(time)
end

function unwrap_path(path)
    if path.previous then
        local wind = unwrap_path(path.previous)
        table.insert(wind, get_waypoint(path.location));
        return wind
    else
        return { get_waypoint(path.location) }
    end
end

function give_item(actor, item)
    actor.inventory[item] = items[item]
end

function remove_item(actor, item)
    actor.inventory[item] = nil
end