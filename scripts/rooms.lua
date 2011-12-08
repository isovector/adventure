rooms = { }

function rooms.create(id)  
    local room = {
        id = id,
        scene = { },
        hotspots = { },
        
        events = { 
            init = event.create(),
            load = event.create(),
            
            enter = event.create(),
            exit = event.create()
        },
        
        enabled_paths = { }
    }

    local roompath = "game/rooms/" .. id .. "/"
    
    room.artwork = bitmap(roompath .. "art.pcx")
    room.hotmap = bitmap(roompath .. "hot.pcx")

    
    
    for i = 1, 254 do
        table.insert(room.enabled_paths, false)
    end
    
    table.insert(room.enabled_paths, true)
    
    rooms.prototype(room)
    rooms[id] = room
    
    return room
end

function rooms.prototype(room)
    function room.switch(door)
        if _G["room"] == room then
            return
        end
        
        conversation.clear()
        events.room.unload(room) -- make this cancelable?
        
        _G["room"] = room
        set_room_data(room.artwork, room.hotmap)

        room.events.load()
        events.room.switch()
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
        room.hotspots[id] = {
            shade = shade,
            id = id,
            name = name,
            cursor = 5,
        
            events = {
                touch = event.create(),
                talk = event.create(),
                look = event.create(),
                item = event.create(),
            
                press = event.create(),
                release = event.create(),
            
                enter = event.create(),
                exit = event.create()
            },
            
            contains = function(pos)
                return shade == which_hotspot(pos)
            end
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
    
    function room.is_walkable(pos, y)
        if y then
            pos = vec(pos, y)
        end
        
        return room.enabled_paths[is_walkable(room.hotmap, pos)]
    end
    
    function room.enable_path(key, val)
        if not val then
            val = true
        end
        
        room[key] = val
    end
    
    room.events.load.sub(function()
        --for key, hs in ipairs(room.hotspots.internal) do
        --    register_hotspot(hs.shade, hs.id, hs.name)
        --end
    end)
end