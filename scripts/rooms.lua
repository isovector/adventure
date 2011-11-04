rooms = { }

function rooms.create(id)  
    local room = {
        id = id,
        scene = { },
        hotspots = { internal = { } },
        events = { 
            init = event.create(),
            load = event.create(),
            
            enter = event.create(),
            exit = event.create()
        }
    }

    local roompath = "game/rooms/" .. id .. "/"
    
    room.artwork = get_bitmap(roompath .. "art.pcx")
    room.hotmap = get_bitmap(roompath .. "hot.pcx")

    rooms.prototype(room)
    rooms[id] = room
    
    return room
end

function rooms.prototype(room)
    function room.load(door)
        -- make this better!
        switch_room(room.id, door)
    end
    
    function room.place(actor, pos)
        -- make THIS better too!
        -- ideally check character positions rather than the scene
        table.insert(room.scene, actor)
        
        if pos then
            actor.pos = pos
        end
    end
    
    function room.hotspot(shade, id, name)
        table.insert(room.hotspots.internal, { shade = shade, id = id, name = name })
        
        room.hotspots[id] = {
            touch = event.create(),
            talk = event.create(),
            look = event.create(),
            item = event.create(),
            
            press = event.create(),
            release = event.create(),
            
            enter = event.create(),
            exit = event.create()
        }
    end
    
    -- fix this to be more like room.hotspot
    function room.door(shade, id, name, dest, door, direction)
        register_hotspot(shade, id, name)
        register_door(id, dest, door, direction)
    end
    
    function room.foreground(shade, baseline)
        register_foreground(shade, baseline)
    end
    
    room.events.load.sub(function()
        for key, hs in ipairs(room.hotspots.internal) do
            register_hotspot(hs.shade, hs.id, hs.name)
        end
    end)
end