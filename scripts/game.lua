framerate = 60 -- this should be "magic" from the engine

function tick(state)
    local elapsed = 1 / framerate
    tasks.update(elapsed * 1000)
    conversation.pump_words(elapsed)

    for key, actor in pairs(room.scene) do
        if actor.aplay then
            animation.play(actor.aplay, elapsed)
        end

        if state == "game" then
            update_actor(actor, elapsed)
        end
    end

    table.sort(room.scene, zorder_sort)
end

function update_actor(actor, elapsed)
    local name = actor.id

    if actor.goal and type(actor.goal) ~= "boolean" then
        if actor.aplay then
            animation.switch(actor.aplay, "walk")
        end

        local speed = actor.speed * elapsed
        local dif = vector.diff(actor.pos, actor.goal)

        if vector.length(dif) > speed then
            local dir = vector.normal(dif)

            if dir.x < 0 then
                actor.flipped = true
            else
                actor.flipped = false
            end

            actor.pos.x = actor.pos.x + dir.x * speed
            actor.pos.y = actor.pos.y + dir.y * speed
        else
            actor.pos = actor.goal
            actor.goal = nil

            if actor.goals and actor.goals[1] then
                actor.goal = actor.goals[1]
                table.remove(actor.goals, 1)
            end
            
            if type(actor.goal) == "function" then
                -- schedule our goal function and wait for it to exit
                -- before resuming our path
                tasks.begin({ actor.goal, function() actor.goal = nil end })
                actor.goal = true
                
                if actor.aplay then
                    animation.switch(actor.aplay, "stand")
                end
            end

            if not actor.goal then
                do_callback("event", name, "goal")

                if actor.aplay then
                    animation.switch(actor.aplay, "stand")
                end
            end
        end
    end
end

function zorder_sort(a, b)
    if not a or not b then
	return a
    end

    ah = a.height
    bh = b.height

    if not ah then ah = 0 end
    if not bh then bh = 0 end

    return a.pos.y + ah < b.pos.y + bh
end

-- this should be implemented in C
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

            if not path then return nil end

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

    if actor.goals then
        table.insert(actor.goals, to)
    end
end

function unwrap_path(path)
    if not path then return nil end

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
