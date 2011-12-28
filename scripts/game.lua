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

events.game.tick.sub(engine.update)

events.game.tick.sub(clock.tick)
events.game.tick.sub(tasks.update)
events.game.tick.sub(conversation.pump_words)
events.game.tick.sub(function() table.sort(room.scene, zorder_sort) end)

events.game.tick.sub(function()
    for _, hotspot in pairs(room.hotspots) do
        for _, actor in pairs(hotspot.owned_actors) do
            if not hotspot.contains(actor.pos) then
                hotspot.owned_actors[actor] = nil
                hotspot.events.unweigh(actor)
            end
        end
    end
end)

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
    local sx = actor.size.x
    local sy = actor.size.y
    local ox = actor.origin.x
    local oy = actor.origin.y
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