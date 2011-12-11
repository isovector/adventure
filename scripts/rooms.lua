rooms = { }

function rooms.create(id)  
    local room = {
        id = id,
        scene = { },
        hotspots = { },
        hotspots_by_shade = { },
        
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
    
    function room.get_hotspot(pos)
        local shade = which_hotspot(pos)
        
        if room.hotspots_by_shade[shade] then
            return room.hotspots_by_shade[shade]
        end
        
        return nil
    end
    
    function room.hotspot(shade, id, name)
        room.hotspots[id] = {
            shade = shade,
            id = id,
            name = name,
            cursor = 5,
            
            owned_actors = { },
        
            events = {
                item = event.create(),
            
                press = event.create(),
                release = event.create()
            },
            
            contains = function(pos)
                return shade == which_hotspot(pos)
            end
        }
        
        -- create events for all the verbs
        for vid, verb in pairs(engine.verbs) do
            room.hotspots[id].events[vid] = event.create()
        end
        
        room.hotspots_by_shade[shade] = room.hotspots[id]
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
    
    -- TODO(sandy): make this work
    function room.enable_path(key, val)
        if not val then
            val = true
        end
        
        --room[key] = val
    end
end