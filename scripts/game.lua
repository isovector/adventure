events.game = {
    tick = event.create()
}

events.game.tick.sub(function(state)
    local elapsed = 1 / framerate
    
    for key, actor in pairs(room.scene) do
        if actor.aplay then
            animation.play(actor.aplay, elapsed)
        end

        if state == "game" and actor.events then
            actor.events.tick(nil, actor, elapsed)
        end
    end
end)

events.game.tick.sub(engine.interface)

events.game.tick.sub(clock.tick)
events.game.tick.sub(tasks.update)
events.game.tick.sub(conversation.pump_words)
events.game.tick.sub(function () table.sort(room.scene, zorder_sort) end)

function get_size(actor)
    if actor.aplay then
        return actor.aplay.set.width, actor.aplay.set.height
    elseif actor.sprite then
        return actor.sprite.size.x, actor.sprite.size.y
    else
        return 0, 0
    end
end

function make_walkspot(actor)
    if type(actor) == "string" then
        actor = table.find(room.scene, function(key, val)
            return val.id == actor
        end)
    end
    
    if not actor then return vec(0) end
    
    if actor.walkspot then
        return vec(actor.walkspot.x, actor.walkspot.y)
    end

    local x = actor.pos.x
    local y = actor.pos.y
    local sx, sy = get_size(actor)
    local ox, oy = get_origin(actor)
    local flip = 1
    
    if actor.flipped then flip = -1 end
    
    x = x - ox + sx
    y = y - oy + sy
    
    
    for dist = sx / 2, sx * 5, sx / 2 do
        for degree = 0, math.pi, math.pi / 12 do
            local ax = math.cos(degree) * dist * flip
            local ay = math.sin(degree) * dist
            
            if room.is_walkable(x + ax, y + ay) then
                return vec(x + ax, y + ay)
            end
        end
    end
    
    return vec(x, y)
end

function get_origin(actor)
    if not actor then return 0, 0 end

    if type(actor) == "string" then
        actor = table.find(room.scene, function(key, val)
            return val.id == actor
        end)
    end
    
    if actor.aplay then
        return actor.aplay.set.xorigin, actor.aplay.set.yorigin
    end
    
    if actor.height then
        return 0, actor.height
    end
    
    return 0, 0
end

function zorder_sort(a, b)
    if not a or not b then
        return a
    end
    
    ah = a.height
    bh = b.height
    
    ay = a.baseline
    by = b.baseline
    
    if not ay then
        ay = a.pos.y
    end
    
    if not by then
        by = b.pos.y
    end

    if not ah then ah = 0 end
    if not bh then bh = 0 end
    
    return ay + ah < by + bh
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
    actor.walk(to, y)
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
