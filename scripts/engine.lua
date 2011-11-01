current_room = ""
room = nil
rooms = {}

events.room = {
    unload = event.create(),
    switch = event.create()
}

function do_callback(callback_type, object, method)
    local name = object .. "_" .. method
    local obj = table.find(room.scene, function(key, val)
            return val.id == object
        end) or { }

    obj.log = "dispatching " ..  callback_type .. " method " .. name .. " on " .. tostring(obj or obj.id)
        
    tasks.begin({
        function()
            if room.events and room.events[name] then
                enable_input(false)
                local result = room.events[name]()
                enable_input(true)
                
                obj.log = "dispatched event as room event"
                
                return result
            end
            return true
        end,
        function()
            if item_events and item_events[name] then
                enable_input(false)
                local result = item_events[name]()
                enable_input(true)
                
                obj.log = "dispatched event as item event"
                
                return result
            end
            return true
        end,
        function()
            if obj and obj.events and obj.events[name] then
                enable_input(false)
                local result = obj.events[name]()
                enable_input(true)
                
                obj.log = "dispatched event as object event"
                
                return result
            end
            return true
        end,
        function()
            if events and events[name] then
                enable_input(false)
                local result = events[name]()
                enable_input(true)
                
                obj.log = "dispatched event as global event"
                
                return result
            end
            return true
        end,
        function()
            if unhandled_event then
                enable_input(false)
                unhandled_event(callback_type, object, method)
                enable_input(true)
                
                obj.log = "failed to dispatch event " .. name
            end
        end,
    }, true)
end

function register_foreground(level, baseline)
    table.insert(room.scene, { baseline = baseline, level = level })
end

function unhandled_event(callback_type, object, method)
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
        switch_room(room, door)
    end)
end

function switch_room(r, door)
    if room then 
        room.log = "switching to room " .. r .. " via door " .. door
    end
    
    if current_room ~= r and room and room.on_unload then
        conversation.clear()
        
        events.room.unload(current_room, r, door)
        room.on_unload()
    end

    if not rooms[r] then
        local roompath = "game/rooms/" .. r .. "/"

        dofile(roompath .. "room.lua")
        room.artwork = get_bitmap(roompath .. "art.pcx")
        room.hotmap = get_bitmap(roompath .. "hot.pcx")

        if room.on_init then
            room.on_init()
        end
        
        rooms[r] = room
    end

    if current_room ~= r then 
        room = rooms[r]
        current_room = r
        
        set_room_data(room.artwork, room.hotmap)
        room.on_load(door)
        
        events.room.switch(r, door)
    end
    
    if player then 
        player.pos = get_walkspot(door)
        animation.switch(player.aplay, "stand")
        player.goal = nil
    end
end