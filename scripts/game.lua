framerate = 60 -- this should be "magic" from the engine

function tick(state)
    local elapsed = 1 / framerate
    tasks.update(elapsed * 1000)
    conversation.pump_words(elapsed)

    for key, actor in pairs(room.scene) do
	local name = actor.id
        animation.play(actor.aplay, elapsed)

        if state == "game" then
            if actor.goal then
                animation.switch(actor.aplay, "walk")

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

                    if not actor.goal then
                        do_callback("event", name, "goal")
                    end
                end
            else
                animation.switch(actor.aplay, "stand")
            end
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
