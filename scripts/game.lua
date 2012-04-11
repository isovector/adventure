load.script("scripts/actor.lua")
load.script("scripts/room.lua")
load.script("scripts/item.lua")

game = {
    hovertext = "",
    life = 0,

    cursors = {
        offsets = {
            vector(16, 16),
            vector(3, 27),
            vector(16, 29),
            vector(29, 27),
            vector(3, 16),
            vector(16, 16),
            vector(29, 16),
            vector(3, 5),
            vector(16, 3),
            vector(29, 5),
            vector(16, 16)
        }
    },
    
    resources = {
        action_bar = load.image("resources/actionbar.pcx"),
        cursors = load.image("resources/cursors.pcx"),
        inventory = load.image("resources/inventory.pcx")
    },
    
    verbs = { }
}

game.inventory_rect = rect.create(vector(270, 210), game.resources.inventory.size)

function game.register_actor_updates()
    load.script("scripts/costume.lua")
    load.script("scripts/path.lua")

    local function update(state)
        local elapsed = 1 / framerate
        
        for key, actor in pairs(room.scene) do
            actor.costume:update(elapsed)

            if state == "game" and actor.events then
                actor.events.tick(nil, actor, elapsed)
            end
        end
    end
    
    local function sort()
        local function zorder_sort(a, b)
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
    
        table.sort(room.scene, zorder_sort) 
    end
    
    local function unweigh()
        for _, hotspot in pairs(room.hotspots) do
            for _, actor in pairs(hotspot.owned_actors) do
                if not hotspot.contains(actor.pos) then
                    hotspot.owned_actors[actor] = nil
                    hotspot.events.unweigh(actor)
                end
            end
        end
    end

    events.game.tick.sub(update)
    events.game.tick.sub(sort)
    events.game.tick.sub(unweigh)
end
    
function game.register_clock()
    load.script("scripts/clock.lua")
    events.game.tick.sub(clock.tick)
end
    
function game.register_conversation()
    load.script("scripts/dialogue.lua")
    events.game.tick.sub(conversation.pump_words)
end

function game.make_walkspot(actor)
    if type(actor) == "string" then
        actor = table.find(room.scene, function(key, val)
            return val.id == actor
        end)
    end
    
    if not actor then return vector(0) end
    
    if actor.walkspot then
        return vector(actor.walkspot.x, actor.walkspot.y)
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
    
    
    for dist = sx * 1.5, sx * 5, sx / 2 do
        for degree = 0, math.pi, math.pi / 12 do
            local ax = math.cos(degree) * dist * flip
            local ay = math.sin(degree) * dist
            
            if room:is_walkable(x + ax, y + ay) then
                return vector(x + ax, y + ay)
            end
        end
    end
    
    return vector(x, y)
end

function game.dispatch(callback_type, object, method)
    local item_type = nil
    local is_item = true
    
    for verb, _ in pairs(game.verbs) do
        if method == verb then
            is_item = false
        end
    end
    
    if is_item then
        item_type = method
        method = "item"
    end
    
    if callback_type == "hotspot" then
        if room.hotspots[object] and room.hotspots[object].events[method] then
            tasks.begin(function()
                --enable_input(false)
                room.hotspots[object].events[method](player, room.hotspots[object], item_type)
                --enable_input(true)
            end)
        end

    elseif callback_type == "object" then
        local obj = table.find(room.scene, function(key, val)
            return val.id == object
        end)

        if obj.events and obj.events[method] then
            tasks.begin(function()
                --enable_input(false)
                obj.events[method](player, obj, item_type)
                --enable_input(true)
            end)
        end
        
    elseif callback_type == "item" then
        local obj = items[object]
        
        if obj and obj.events and obj.events[method] then
            tasks.begin(function()
                --enable_input(false)
                obj.events[method](player, obj, item_type)
                --enable_input(true)
            end)
        end
    end
end

function game.append_dispatch(actor, callback_type, object, method, flipped)
    if not actor then return end
    
    actor.queue(function()
        actor.flipped = flipped
        game.dispatch(callback_type, object, method)
    end)
end

function game.add_verb(name, use, offset, size)
    game.verbs[name] = {
        use = use,
        offset = offset,
        size = size
    }
end

function game.set_action(type, id, name, spot, flip)
    if not flip then
        flip = false
    end

    engine.action = {
        active = false,
        flip = flip,
        type = type,
        object = id,
        name = name,
        pos = input.mouse.pos - (game.resources.action_bar.size * 0.5),
        spot = spot,
        activates_at = game.life + 0.5
    }
end