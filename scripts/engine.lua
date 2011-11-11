room = nil
rooms = { }

engine = {
    life = 0,
    state = "game",
    fps = 0,
    allow_input = true,
    
    events = {
        draw = event.create()
    },
    
    mouse = {
        cursor = 0,
        pos = vec(0),
        buttons = {
            left = false,
            middle = false,
            right = false,
            
            last_left = false,
            last_middle = false,
            last_right = false
        }
    },
    
    cursors = {
        image = bitmap("resources/cursors.pcx"),
        offsets = {
            vec(16, 16),
            vec(3, 27),
            vec(16, 29),
             vec(29, 27),
             vec(3, 16),
             vec(16, 16),
             vec(29, 16),
             vec(3, 5),
             vec(16, 3),
             vec(29, 5)
        }
    }
}

function engine.mouse.is_click(button)
    return engine.mouse.buttons[button] 
        and not engine.mouse.buttons["last_" .. button]
end

function engine.mouse.is_anticlick(button)
    return not engine.mouse.buttons[button] 
        and engine.mouse.buttons["last_" .. button]
end

engine.events.draw.sub(function()
    if room and room.artwork then
        drawing.blit(room.artwork, vec(0), false, vec(0), room.artwork.size)
        
        for _, actor in ipairs(room.scene) do
            if actor.aplay then
                local set = actor.aplay.set
                drawing.blit(set.image, actor.pos - actor.origin, actor.flipped, vec(animation.get_frame(set, actor.aplay.frame)), actor.size)
            elseif actor.sprite then
                drawing.blit(actor.sprite, actor.pos, actor.flipped, vec(0), actor.sprite.size)
            end
        end
    else
        drawing.clear(color.black)
        drawing.text(vec(32, 32), color.make(255, 200, 0), color.transparent, "Room failed to load")
        drawing.text(vec(32, 46), color.make(255, 200, 0), color.transparent, "This is generally indicative of a big lua problem")
    end
    
    drawing.blit(engine.cursors.image, engine.mouse.pos - engine.cursors.offsets[engine.mouse.cursor + 1], false, vec(32 * engine.mouse.cursor, 0), vec(32))
end)

events.room = {
    unload = event.create(),
    switch = event.create()
}

--disable_input: this should be ALL lua; remove the c primitives
--engine.action: port the action_state object from C, obj -> object
----walkspot -> spot
--make actor.size
--engine.tooltip -> c's object_name

function engine.interface()
    local elapsed = 1 / framerate
    engine.life = engine.life + elapsed

    if not engine.allow_input then return end
    
    local action = engine.action
    local item = engine.item
    local mouse = engine.mouse
    
    mouse.cursor = 0
    
    if engine.action then
        if action.spot then
            player.walk(action.spot)
        end
        
        append_dispatch(player, action.type, action.object, action.method, action.flip)
        
        action.result = nil
    end
    
    local found = false
    for _, actor in ipairs(room.scene) do
        if actor.pos then -- flush out foreground elements
            local hitbox = rect.create(actor.pos - actor.origin, actor.size)
            if hitbox.contains(mouse.pos) then
                --[[or pixel perfect]]
                found = 1
                mouse.cursor = 5
                
                if mouse.is_click("left") then
                    if item then
                        do_callback(item.type, item.object, item.method)
                        engine.item = nil
                    else
                        local spot = make_walkspot(actor)
                        engine.action = {
                            type = "object",
                            object = actor.name,
                            spot = spot,
                            activates_at = engine.life + 0.5
                        }
                    end
                end
            end
        end
    end
    
    if not found then
        for _, hotspot in pairs(room.hotspots) do
            if hotspot.contains(mouse.pos) then
                engine.tooltip = hotspot.name
                mouse.cursor = hotspot.cursor
                found = true
                
                if mouse.is_click("left") then
                    if item then
                        player.walk(hotspot.spot)
                        do_callback(item.type, item.object, item.method)
                        engine.item = nil
                    else -- something about doors?
                        engine.action = {
                            type = "hotspot",
                            object = hotspot.id,
                            spot = hotspot.spot,
                            activates_at = engine.life + 0.5
                        }
                    end
                end
            end
        end
    end
    
    if not found and mouse.is_click("left") then
        if room.is_walkable(mouse.pos) then
            player.walk(mouse.pos)
        end
        
        engine.action = nil
    end
    
    if mouse.buttons.left and engine.action then
        if life >= action.activates_at then
            action.last_state = "game"
            engine.state = "action"
        end
    elseif mouse.is_click("right") then
        engine.action = nil
        
        if item then
            engine.item = nil
        else
            engine.state = "inventory"
        end
    end
    
    for button, value in pairs(mouse.buttons) do
        if type(mouse.buttons["last_" .. button]) ~= "nil"  then
            mouse.buttons["last_" .. button] = mouse.buttons[button]
        end
    end
end




function do_callback(callback_type, object, method)
    local item_type
    
    if  method ~= "touch" and
        method ~= "talk" and
        method ~= "look" and
        method ~= "door" then
        item_type = method
        method = "item"
    end

    if callback_type == "hotspot" then
        if room.hotspots[object] and room.hotspots[object][method] then
            tasks.begin(function()
                --enable_input(false)
                room.hotspots[object][method](player, room.hotspots[object], item_type)
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

function register_foreground(level, baseline)
    table.insert(room.scene, { baseline = baseline, level = level })
end

function append_dispatch(actor, callback_type, object, method, flipped)
    if not actor or not actor.goals then return end
    
    table.insert(actor.goals, function()
        actor.flipped = flipped
        do_callback(callback_type, object, method)
    end)
end

function append_switch(actor, room, door)
    if not actor.goals then return end

    table.insert(actor.goals, function()
        -- TODO(sandy): do something about doors
        rooms[room].switch()
    end)
end