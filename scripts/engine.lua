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
    
    actionbar = bitmap("resources/actionbar.pcx"),
    
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

events.room = {
    unload = event.create(),
    switch = event.create()
}


function engine.callback(callback_type, object, method)
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
    
    print(actor, callback_type, object, method, flipped)
    
    table.insert(actor.goals, function()
        actor.flipped = flipped
        engine.callback(callback_type, object, method)
    end)
end

function append_switch(actor, room, door)
    if not actor.goals then return end

    table.insert(actor.goals, function()
        -- TODO(sandy): do something about doors
        rooms[room].switch()
    end)
end