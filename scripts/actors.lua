actors = { } 

function actors.temp(id, name, cost)
    local actor = { 
        id = id,
        name = name,
        
        pos = vector(0),
        ignore_ui = false,
        flipped = false,
        speed = 150,
        color = 0xFFFFFF,
        follow = false,
        
        walkcount = 0,
        
        goal = nil,
        goals = { },
        inventory = { },
        
        size = vector(0),
        origin = vector(0),
        pathsize = vector(0),
        
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
        },
        
        costume = cost
    }
    
    -- create events for all the verbs
    for id, verb in pairs(game.verbs) do
        actor.events[id] = event.create()
    end
    
    actor.costume.refresh_anim()
    
    return actor
end

function actors.create(id, name, costume)
    actors[id] = actors.temp(id, name, costume)
    actors.prototype(actors[id])
    return actors[id]
end

function actors.prototype(actor)
    actor.events.tick.sub(function(sender, target, elapsed)
        local name = actor.id

        if actor.goal and type(actor.goal) ~= "boolean" then
            actor.costume.set_pose("walk")

            if type(actor.goal) == "userdata" then
                local speed = actor.speed * elapsed
                local dir = actor.goal - actor.pos

                if dir:Length() > speed then
                    dir:Normalize();
                    
                    if math.abs(dir.x) > math.abs(dir.y) then
                        if dir.x > 0 then
                            actor.costume.set_direction(6)
                        else
                            actor.costume.set_direction(4)
                        end
                    else
                        if dir.y > 0 then
                            actor.costume.set_direction(2)
                        else
                            actor.costume.set_direction(8)
                        end
                    end
                    
                    local hotspot = room.get_hotspot(actor.pos)
                    if hotspot and not hotspot.owned_actors[actor] then
                        hotspot.owned_actors[actor] = actor
                        hotspot.events.weigh(actor)
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
                    
                    actor.costume.set_pose("idle")

                    if not actor.goal then
                        actor.events.goal()
                    end
                    
                    actor.compress_goals()
                end
            elseif type(actor.goal) == "function" then
                actor.costume.set_pose("idle")
            
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

            if actor.pos and pos and pathfinding.is_pathable(actor.pos, pos) then
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
            actor.walk(game.make_walkspot(recip))
            
            actor.queue(function()
                actor.lose_item(item)
                recip.obtain_item(item)
            end)
        end
    end
    
    function actor.use_door(door)
        door = room.hotspots[door]
    
        actor.walk(door.spot)
        actor.queue(function()
            local newroom = rooms[door.door.exit_room]
            local newdoor = newroom.hotspots[door.door.exit_door]
        
            actor.events.exit(actor, room)
            
            table.remove(room.scene, table.contains(room.scene, actor))
            newroom.place(actor)
            
            if newdoor and newdoor.spot then
                actor.pos = vector(newdoor.spot)
            end
            
            actor.events.enter(actor, newroom)
            
            if actor.follow then
                newroom.switch()
            end
        end)
    end
    
    function actor.walk(to, y)
        if y then 
            to = vector(to, y)
        else
            to = vector(to)-- get a new vector
        end
        
        if pathfinding.is_pathable(actor.pos, to) then
            actor.goal = to
            actor.goals = nil
        else
            actor.goals = pathfind(pathfinding.get_closest_waypoint(actor.pos), pathfinding.get_closest_waypoint(to))

            if actor.goals then
                actor.goal = pathfinding.get_waypoint(pathfinding.get_closest_waypoint(actor.pos))
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
        msg = conversation.say(message, actor.pos - vector(0, actor.origin.y + 20), actor.color)
        wait(msg.duration * 1000)
    end
end