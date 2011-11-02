actors = { } 

function actors.create(id, name, bitmap, xframes, yframes)
    local actor = { 
        id = id,
        name = name,
        
        pos = vec(0, 0),
        ignore_ui = false,
        flipped = false,
        speed = 150,
        color = 0xFFFFFF,
        
        goal = nil,
        goals = { },
        inventory = { },
        
        events = {
            goal = event.create(),
            
            touch = event.create(),
            talk = event.create(),
            look = event.create(),
            
            idle = event.create(),
            walk = event.create(),
            
            enter = event.create(),
            exit = event.create()
        }
    }
    
    -- HACK(sandy): this really should create an aplay given xyframes
    if not xframes then
        actor.sprite = get_bitmap(bitmap)
    else
        actor.aplay = bitmap
    end
    
    actors[id] = actor
    return actor
end