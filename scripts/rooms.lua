rooms = { }

function rooms.create(id)
    local room = {
        id = id,
        scene = { },
        events = { 
            init = event.create(),
            load = event.create(),
            
            enter = event.create(),
            exit = event.create(),
        }
    }

    local roompath = "game/rooms/" .. r .. "/"

    room.artwork = get_bitmap(roompath .. "art.pcx")
    room.hotmap = get_bitmap(roompath .. "hot.pcx")
    
    room = rooms.prototype(room)
    
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
        actor.pos = pos
    end
    
    function room.hotspot(shade, id, name)
        register_hotspot(shade, id, name)
    end
    
    function room.door(shade, id, name, dest, door, direction)
        room.hotsopt(shade, id, name)
        register_door(id, dest, door, direction)
    end
end