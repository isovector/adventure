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

local logic = function()
    if engine.mouse.is_click("left") then
        table.insert(vertices, vec(engine.mouse.pos))
        vertices[#vertices].n = string.sub("abcdefghijklmnopqrstuvwxyz", #vertices, #vertices)
    end
    
    if engine.mouse.is_click("right") then
        vertices[#vertices] = nil
    end
    
    if engine.keys.is_press("space") then
        triangles = get_navmesh(vertices)
        vertices = { }
    end
    
    if engine.keys.is_press("c") then
        vertices = { }
        triangles = { }
    end

    engine.mouse.pump()
    engine.keys.pump()
end

events.game.tick.sub(logic)