function pathfind(from, to)
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
            if to == path.location then return unwrap_path(path) end
            table.insert(closed, path.location)

            for key, val in ipairs(pathfinding.get_neighbors(path.location)) do
                local dist = heuristic(path.location, pathfinding.get_waypoint(val))
                pqueue.enqueue(open, -(path.cost + dist), add_path(path, val, path.cost + dist))
            end
        until true
        if not continue then break end
    end
end

function unwrap_path(path)
    if not path then return nil end

    if path.previous then
        local wind = unwrap_path(path.previous)
        table.insert(wind, pathfinding.get_waypoint(path.location));
        return wind
    else
        return { pathfinding.get_waypoint(path.location) }
    end
end

function heuristic(from, to)
    return 1
    --return (get_waypoint(from) - get_waypoint(to)).len()
end