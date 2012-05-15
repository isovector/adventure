room = nil
rooms = { }

events.room = {
    unload = event.create(),
    switch = event.create()
}

newclass("Room", 
    function(id, art, hot)
        local room = {
            id = id,
            scene = { },
            hotspots = { },
            hotspots_by_shade = { },
            
            artwork = art,
            hotmap = hot,
            
            events = { 
                init = event.create(),
                load = event.create(),
                
                enter = event.create(),
                exit = event.create()
            },
            
            walkspots = pathfinding.get_walkspots(hot),
            
            enabled_paths = { }
        }

        for i = 1, 254 do
            table.insert(room.enabled_paths, false)
        end
        
        table.insert(room.enabled_paths, true)
        
        rooms[id] = room
        return room
    end
)

function Room:switch(door)
    if room == self then
        return
    end
    
    conversation.clear()
    events.room.unload(self) -- make this cancelable?
    
    room = self
    pathfinding.load_room(self.hotmap)
    
    for path, enabled in ipairs(self.enabled_paths) do
        pathfinding.enable_path(path, enabled)
    end
    pathfinding.rebuild_waypoints()

    self.events.load()
    events.room.switch()
end

function Room:place(actor, pos)
    table.insert(self.scene, actor)
    
    if pos then
        actor.pos = pos
    end
end

function Room:get_hotspot(pos)
    local shade = pathfinding.which_hotspot(pos)
    
    if self.hotspots_by_shade[shade] then
        return self.hotspots_by_shade[shade]
    end
    
    return nil
end

function Room:hotspot(shade, id, name)
    self.hotspots[id] = {
        shade = shade,
        id = id,
        name = name,
        cursor = 5,
        spot = [0, 0],
        
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
        self.hotspots[id].events[vid] = event.create()
    end
    
    if self.walkspots[shade] then
        self.hotspots[id].spot = self.walkspots[shade]
    end
    
    self.hotspots_by_shade[shade] = self.hotspots[id]
end

function Room:door(shade, id, name, dest, door, direction)
    self:hotspot(shade, id, name)
    
    local hotspot = self.hotspots[id]
    hotspot.cursor = direction
    hotspot.clickable = true
    
    hotspot.door = {
        is_door = true,
        exit_room = dest,
        exit_door = door
    }
    
    hotspot.events.click.sub(function()
        player:use_door(id)
    end)
end

function Room:foreground(shade, baseline)
    --[[local fg, pos = drawing.mask_copy(self.artwork, self.hotmap, shade)

    table.insert(self.scene, { 
        baseline = baseline, 
        sprite = fg,
        pos = pos,
        flipped = false
    })]]
end

function Room:is_walkable(pos, y)
    if y then
        pos = [pos, y]
    end
    
    return self.enabled_paths[pathfinding.is_walkable(self.hotmap, pos)]
end

function Room:enable_path(key, val)
    if not val then
        val = true
    end
    
    self.enabled_paths[key] = val
    pathfinding.enable_path(key, val)
    pathfinding.rebuild_waypoints()
end
