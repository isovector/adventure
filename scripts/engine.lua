room = nil
rooms = { }

engine = {
    life = 0,
    state = "game",
    fps = 0,
    allow_input = true,
    
    hovertext = "",
    
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
    
    keys = {
        pressed = { },
        released = { }
    },
    
    cursors = {
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
            vec(29, 5),
            vec(16, 16)
        }
    },
    
    resources = {
        action_bar = bitmap("resources/actionbar.pcx"),
        cursors = bitmap("resources/cursors.pcx"),
        inventory = bitmap("resources/inventory.pcx")
    },
    
    verbs = { }
}

events.game = {
    tick = event.create()
}

events.console = {
    input = event.create()
}

function engine.add_verb(name, use, offset, size)
    engine.verbs[name] = {
        use = use,
        offset = offset,
        size = size
    }
end

function engine.set_action(type, id, name, spot, flip)
    if not flip then
        flip = false
    end

    engine.action = {
        active = false,
        flip = flip,
        type = type,
        object = id,
        name = name,
        pos = engine.mouse.pos - (engine.resources.action_bar.size * 0.5),
        spot = spot,
        activates_at = engine.life + 0.5
    }
end

function engine.mouse.is_click(button)
    return engine.mouse.buttons[button] 
        and not engine.mouse.buttons["last_" .. button]
end

function engine.mouse.is_upclick(button)
    return not engine.mouse.buttons[button] 
        and engine.mouse.buttons["last_" .. button]
end

function engine.mouse.pump()
    local mouse = engine.mouse

    for button, value in pairs(mouse.buttons) do
        if type(mouse.buttons["last_" .. button]) ~= "nil"  then
            mouse.buttons["last_" .. button] = mouse.buttons[button]
        end
    end
end

function engine.keys.is_press(key)
    return engine.keys.pressed[key]
end

function engine.keys.is_release(key)
    return engine.keys.released[key]
end

function engine.keys.pump()
    engine.keys.pressed = { }
    engine.keys.released = { }
end

events.room = {
    unload = event.create(),
    switch = event.create()
}


function engine.callback(callback_type, object, method)
    local item_type = nil
    local is_item = true
    
    for verb, _ in pairs(engine.verbs) do
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

function register_foreground(level, baseline)
    room.register_foreground(level, baseline)
end

function append_dispatch(actor, callback_type, object, method, flipped)
    if not actor then return end
    
    actor.queue(function()
        actor.flipped = flipped
        engine.callback(callback_type, object, method)
    end)
end

function append_switch(actor, room, door)
    if not actor then return end
    
    actor.queue(function()
        -- TODO(sandy): do something about doors
        rooms[room].switch()
    end)
end