actors = { } 

function actors.temp(id, name, bmpfile, xframes, yframes)
    local actor = { 
        id = id,
        name = name,
        
        pos = vec(0, 0),
        ignore_ui = false,
        flipped = false,
        speed = 150,
        color = 0xFFFFFF,
        
        walkcount = 0,
        
        goal = nil,
        goals = { },
        inventory = { },
        
        events = {
            goal = event.create(),
            
            item = event.create(),
            
            obtain = event.create(),
            lose = event.create(),
            
            tick = event.create(),
            idle = event.create(),
            walk = event.create(),
            
            enter = event.create(),
            exit = event.create()
        }
    }
    
    -- create events for all the verbs
    for id, verb in pairs(engine.verbs) do
        actor.events[id] = event.create()
    end
    
    -- HACK(sandy): this really should create an aplay given xyframes
    if not xframes then
        actor.sprite = bitmap(bmpfile)
        actor.size = actor.sprite.size
        actor.origin = vec(0)
    else
        actor.aplay = bmpfile
        actor.size = vec(actor.aplay.set.width, actor.aplay.set.height)
        actor.origin = vec(actor.aplay.set.xorigin, actor.aplay.set.yorigin)
    end
    
    return actor
end

function actors.create(id, name, bmp, xframes, yframes)
    actors[id] = actors.temp(id, name, bmp, xframes, yframes)
    actors.prototype(actors[id])
    return actors[id]
end

function actors.prototype(actor)
    actor.events.tick.sub(function(sender, target, elapsed)
        local name = actor.id

        if actor.goal and type(actor.goal) ~= "boolean" then
            if actor.aplay then
                animation.switch(actor.aplay, "walk")
            end
            
            if type(actor.goal) == "table" then
                actor.goal = actor.goal
            
                local speed = actor.speed * elapsed
                local dif = actor.goal - actor.pos

                if dif.len() > speed then
                    local dir = dif.normal()

                    if dir.x < 0 then
                        actor.flipped = true
                    else
                        actor.flipped = false
                    end
                    
                    local hotspot = room.get_hotspot(actor.pos)
                    if hotspot and not hotspot.owned_actors[actor] then
                        hotspot.owned_actors[actor] = actor
                        hotspot.events.press(actor)
                    end

                    actor.pos.x = actor.pos.x + dir.x * speed
                    actor.pos.y = actor.pos.y + dir.y * speed
                    
                    actor.walkcount = actor.walkcount + 1
                    if actor.walkcount % 30 == 0 and actor.goals then
                        actor.compress_goals()
                    end
                else
                    actor.pos = actor.goal
                    actor.goal = nil

                    if actor.goals and actor.goals[1] then
                        actor.goal = actor.goals[1]
                        table.remove(actor.goals, 1)
                    end
                    
                    if actor.aplay then
                        animation.switch(actor.aplay, "stand")
                    end

                    if not actor.goal then
                        actor.events.goal()
                    end
                    
                    actor.compress_goals()
                end
            elseif type(actor.goal) == "function" then
                if actor.aplay then
                    animation.switch(actor.aplay, "stand")
                end
            
                tasks.begin({ actor.goal, function() 
                    if actor.goals and actor.goals[1] then
                        actor.goal = actor.goals[1]
                        table.remove(actor.goals, 1)
                    end
                end })
                actor.goal = true
            end
        end
    end)
    
    function actor.compress_goals()
        local i = 0
        local found = false
        
        if not actor.goals then return end
        
        for _, pos in ipairs(actor.goals) do
            if type(pos) == "function" then break end

            if actor.pos and pos and is_pathable(actor.pos, pos) then
                found = true
                actor.goal = pos
            end
        end
    end
    
    function actor.obtain_item(item)
        if items[item] then
            actor.inventory[item] = items[item]
            actor.events.obtain(actor, item)
        end
    end
    
    function actor.lose_item(item)
        actor.inventory[item] = nil
        actor.events.lose(actor, item)
    end
    
    function actor.give(recip, item)
        if actor.inventory[item] then
            actor.walk(make_walkspot(recip))
            
            actor.queue(function()
                actor.lose_item(item)
                recip.obtain_item(item)
            end)
        end
    end
    
    function actor.walk(to, y)
        if y then 
            to = vec(to, y)
        else
            to = vec(to)-- get a new vector
        end
        
        if is_pathable(actor.pos, to) then
            actor.goal = to
            actor.goals = nil
        else
            actor.goals = pathfind(get_closest_waypoint(actor.pos), get_closest_waypoint(to))

            if actor.goals then
                actor.goal = get_waypoint(get_closest_waypoint(actor.pos))
                table.insert(actor.goals, to)
            end
        end
    end
    
    function actor.queue(func, ...)
        if not actor.goals then
            actor.goals = { }
        end
        
        local args = { ... }

        table.insert(actor.goals, function()
            func(args)
        end)
    end
    
    function actor.say_async(message)
        tasks.begin(function() actor.say(message) end)
    end

    function actor.say(message)
        print(actor.name .. "> " .. message)
        msg = conversation.say(message, actor.pos - vec(0, actor.origin.y + 20), actor.color)
        wait(msg.duration * 1000)
    end
end