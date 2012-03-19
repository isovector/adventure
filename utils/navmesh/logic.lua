function table.score(t, scorer)
    if not scorer then
        scorer = function(a) return a end
    end

    local best_key = nil
    local best_score = nil

    for key, val in pairs(t) do
        local score = scorer(val)
        
        if best_score == nil or score > best_score then    
            best_key = key
            best_score = score
        end
    end
    
    return best_key, best_score
end

function hash(v)
    return v.x .. v.y
end

function build_navmesh(vertices, image)
    local navmesh = {
        vertices = vertices,
        triangles = get_navmesh(vertices),
        edges = { },
        points = { }
    }

    for _, vertex in ipairs(navmesh.vertices) do
        local h = hash(vertex)
    
        navmesh.points[h] = vertex
        navmesh.edges[h] = { }
    end

    for _, triangle in ipairs(navmesh.triangles) do
        for i = 1, 3 do
            local h = hash(triangle[i])
            if not navmesh.edges[h] then
                navmesh.edges[h] = { }
            end
        
            for j = 1, 3 do
                if i ~= j then
                    table.insert(navmesh.edges[h], hash(triangle[j]))
                end
            end
        end
    end
    
    if image then
        local mode = drawing.get_mode()
        drawing.set_mode("xor")
        drawing.polygon(hot, vertices, 0x00FF00)
        drawing.set_mode(mode)
    end
    
    return navmesh
end

function rebuild()
    drawing.clear(hot, 0)
    
    for i, hotspot in ipairs(hotspots) do
        drawing.polygon(hot, hotspot, i * 0x110000)
    end
    
    local mode = drawing.get_mode()
    drawing.set_mode("xor")
    drawing.polygon(hot, navigation, 0x00FF00)
    drawing.set_mode(mode)
    
    for _, waypoint in ipairs(waypoints) do
        drawing.point(hot, waypoint, 0x0000FF)
    end
end

function next_hotspot()
    if curhotspot == #hotspots then
        table.insert(hotspots, { })
    end
    
    curhotspot = curhotspot + 1
    vertices = hotspots[curhotspot]
end

local logic = function()
    if input.mouse.is_click("left") then
        table.insert(vertices, vec(input.mouse.pos))
        vertices[#vertices].n = string.sub("abcdefghijklmnopqrstuvwxyz", #vertices, #vertices)
    end
    
    if input.mouse.is_click("right") then
        vertices[#vertices] = nil
    end
    
    if input.keys.is_press("space") then
        rebuild()
        next_hotspot()
    end
    
    if input.keys.is_press("w") then
        vertices = waypoints
    end
    
    if input.keys.is_press("c") then
        for k in pairs(vertices) do vertices[k] = nil end
    end
    
    if input.keys.is_press("0") then
        vertices = navigation
        curhotspot = 0
    end
    
    for i = 1, 9 do
        if input.keys.is_press(tostring(i)) and hotspots[i] then
            vertices = hotspots[i]
            curhotspot = i
        end
    end

    input.mouse.pump()
    input.keys.pump()
end

events.game.tick.sub(logic)