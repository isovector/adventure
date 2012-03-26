room = nil
rooms = { }

events.room = {
    unload = event.create(),
    switch = event.create()
}

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
    
    room.artwork = load.image(roompath .. "art.pcx")
    room.hotmap = load.image(roompath .. "hot.pcx")
    
    room.walkspots = pathfinding.get_walkspots(room.hotmap)

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
        pathfinding.load_room(room.hotmap)
        
        for path, enabled in ipairs(room.enabled_paths) do
            pathfinding.enable_path(path, enabled)
        end
        pathfinding.rebuild_waypoints()

        room.events.load()
        events.room.switch()
    end
    
    function room.place(actor, pos)
        table.insert(room.scene, actor)
        
        if pos then
            actor.pos = pos
        end
    end
    
    function room.get_hotspot(pos)
        local shade = pathfinding.which_hotspot(pos)
        
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
            spot = vector(0),
            
            clickable = false,
            
            door = {
                is_door = false,
                exit_room = nil,
                exit_door = nil
            },
            
            owned_actors = { },
        
            events = {
                -- default verb for item usage
                item = event.create(),
            
                -- when an actor stands here
                weigh = event.create(),
                
                -- when an actor stops standing here
                unweigh = event.create(),
                
                -- on a mouse press
                click = event.create()
            },
            
            contains = function(pos)
                return shade == pathfinding.which_hotspot(pos)
            end
        }
        
        -- create events for all the verbs
        for vid, verb in pairs(game.verbs) do
            room.hotspots[id].events[vid] = event.create()
        end
        
        if room.walkspots[shade] then
            room.hotspots[id].spot = room.walkspots[shade]
        end
        
        room.hotspots_by_shade[shade] = room.hotspots[id]
    end
    
    function room.door(shade, id, name, dest, door, direction)
        room.hotspot(shade, id, name)
        
        local hotspot = room.hotspots[id]
        hotspot.cursor = direction
        hotspot.clickable = true
        
        hotspot.door = {
            is_door = true,
            exit_room = dest,
            exit_door = door
        }
        
        hotspot.events.click.sub(function()
            player.use_door(id)
        end)
    end
    
    function room.foreground(shade, baseline)
        --[[local fg, pos = drawing.mask_copy(room.artwork, room.hotmap, shade)
    
        table.insert(room.scene, { 
            baseline = baseline, 
            sprite = fg,
            pos = pos,
            flipped = false
        })]]
    end
    
    function room.is_walkable(pos, y)
        if y then
            pos = vector(pos, y)
        end
        
        return room.enabled_paths[pathfinding.is_walkable(room.hotmap, pos)]
    end
    
    function room.enable_path(key, val)
        if not val then
            val = true
        end
        
        room.enabled_paths[key] = val
        pathfinding.enable_path(key, val)
        pathfinding.rebuild_waypoints()
    end
end