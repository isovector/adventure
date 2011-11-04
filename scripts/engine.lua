current_room = ""
room = nil
rooms = {}

events.room = {
    unload = event.create(),
    switch = event.create()
}

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
                enable_input(false)
                room.hotspots[object][method](player, room.hotspots[object], item_type)
                enable_input(true)
            end)
        end
        
    elseif callback_type == "object" then
        local obj = table.find(room.scene, function(key, val)
            return val.id == object
        end)
        
        if obj.events and obj.events[method] then
            tasks.begin(function()
                enable_input(false)
                obj.events[method](player, obj, item_type)
                enable_input(true)
            end)
        end
        
    elseif callback_type == "item" then
        local obj = items[object]
        
        if obj and obj.events and obj.events[method] then
            tasks.begin(function()
                enable_input(false)
                obj.events[method](player, obj, item_type)
                enable_input(true)
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
    end
    
    if not rooms[r] then
        local roompath = "game/rooms/" .. r .. "/"

        dofile(roompath .. "room.lua")
        rooms[r].events.init(r)
    end
    
    if current_room ~= r then 
        room = rooms[r]
        current_room = r
        
        set_room_data(room.artwork, room.hotmap)
        room.events.load(r, door)
        
        events.room.switch(r, door)
    end
    
    if player then 
        player.pos = get_walkspot(door)
        animation.switch(player.aplay, "stand")
        player.goal = nil
    end
end