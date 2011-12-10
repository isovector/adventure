--[[function pathfind(from, to)
    local open = { from }
    local closed = { }
    local came_from = { }
    
    local g_score = { }
    local h_score = { }
    local f_score = { }
    
    g_score[from] = 0
    h_score[from] = heuristic(from, to)
    f_score[from] = g_score[from] + h_score[from]
    
    while table.getn(open) ~= 0 do
        local x = table.min(f_score)
        print("checking x", x)
        if x == to then
            print("yo")
            return { unpack(unwind(came_from, came_from[to])), get_waypoint(to) }
        end
        
        local in_open = table.contains(open, x)
        print("in open", in_open)
        if in_open then
            table.remove(open, in_open)
        end
        
        table.insert(closed, x)
        
        for _, y in ipairs(get_neighbors(x)) do
            print("trying ", x, y)
        
            if not table.contains(closed, y) then
                local tentative = g_score[x] + heuristic(x, y)
                local is_better = false
                
                print("has y? ", x, y, table.contains(open, y))
                
                if not table.contains(open, y) then
                    print("inserting ", y)
                    table.insert(open, y)
                    is_better = true
                elseif tentative < g_score[y] then
                    is_better = true
                end
                
                if is_better then
                    came_from[y] = x
                    g_score[y] = tentative
                    h_score[y] = heuristic(y, to)
                    f_score[y] = g_score[y] + h_score[y]
                end
            end
        end
    end
end

function unwind(came_from, node)
    if came_from[node] then
        return { unpack(unwind(came_from, came_from[node])), get_waypoint(node) }
    else
        return {  }
    end
end]]

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

            for key, val in ipairs(get_neighbors(path.location)) do
                local dist = heuristic(path.location, get_waypoint(val))
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
        table.insert(wind, get_waypoint(path.location));
        return wind
    else
        return { get_waypoint(path.location) }
    end
end

function heuristic(from, to)
    return 1
--    return (get_waypoint(from) - get_waypoint(to)).len()
end