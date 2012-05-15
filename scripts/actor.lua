actors = { } 

newclass("Actor", 
    function(id, name, costume)
        local self = { 
            id = id,
            name = name,
            
            pos = [0, 0],
            ignore_ui = false,
            flipped = false,
            speed = 150,
            color = 0xFFFFFF,
            follow = false,
            
            walkcount = 0,
            
            goal = nil,
            goals = { },
            inventory = { },
            
            size = [0, 0],
            origin = [0, 0],
            pathsize = [0, 0],
            
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
            
            costume = costume
        }
        
        -- create events for all the verbs
        for id, verb in pairs(game.verbs) do
            self.events[id] = event.create()
        end
        
        self.costume:refresh_anim()
        actors[id] = self
        
        self.events.tick.sub(function(...)
            self:update(...)
        end)
        
        return self
    end
)

function Actor:compress_goals()
    local i = 0
    local found = false
    
    if not self.goals then return end
    
    for _, pos in ipairs(self.goals) do
        if type(pos) == "function" then break end

        if self.pos and pos and pathfinding.is_pathable(self.pos, pos) then
            found = true
            self.goal = pos
        end
    end
end

function Actor:obtain_item(item)
    if items[item] then
        self.inventory[item] = items[item]
        self.events.obtain(self, item)
    end
end

function Actor:lose_item(item)
    self.inventory[item] = nil
    self.events.lose(self, item)
end

function Actor:give(recip, item)
    if self.inventory[item] then
        self:walk(game.make_walkspot(recip))
        
        self.queue(function()
            self.lose_item(item)
            recip.obtain_item(item)
        end)
    end
end

function Actor:use_door(door)
    door = room.hotspots[door]

    self:walk(door.spot)
    self:queue(function()
        local newroom = rooms[door.door.exit_room]
        local newdoor = newroom.hotspots[door.door.exit_door]
    
        self.events.exit(self, room)
        
        table.remove(room.scene, table.contains(room.scene, self))
        newroom:place(self)
        
        if newdoor and newdoor.spot then
            self.pos = vector(newdoor.spot)
        end
        
        self.events.enter(self, newroom)
        
        if self.follow then
            newroom:switch()
        end
    end)
end

function Actor:walk(to, y)
    if y then 
        to = vector(to, y)
    else
        to = vector(to)-- get a new vector
    end
    
    if pathfinding.is_pathable(self.pos, to) then
        self.goal = to
        self.goals = nil
    else
        self.goals = pathfind(pathfinding.get_closest_waypoint(self.pos), pathfinding.get_closest_waypoint(to))

        if self.goals then
            self.goal = pathfinding.get_waypoint(pathfinding.get_closest_waypoint(self.pos))
            table.insert(self.goals, to)
        end
    end
end

function Actor:queue(func, ...)
    if not self.goals then
        self.goals = { }
    end
    
    local args = { ... }

    table.insert(self.goals, function()
        func(args)
    end)
end

function Actor:say_async(message)
    tasks.start(function() self:say(message) end)
end

function Actor:say(message)
    msg = conversation.say(message, self.pos - vector(0, self.origin.y + 20), self.color)
    sleep(msg.duration)
end

function Actor:update(sender, target, elapsed)
    local name = self.id

    if self.goal and type(self.goal) ~= "boolean" then
        self.costume:set_pose("walk")

        if type(self.goal) == "userdata" then
            local speed = self.speed * elapsed
            local dir = self.goal - self.pos

            if dir:Length() > speed then
                dir:Normalize();
                
                self.costume:set_direction(dir)
                
                local hotspot = room:get_hotspot(self.pos)
                if hotspot and not hotspot.owned_actors[self] then
                    hotspot.owned_actors[self] = self
                    hotspot.events.weigh(self)
                end

                self.pos = self.pos + dir * speed
                
                self.walkcount = self.walkcount + 1
                if self.walkcount % 30 == 0 and self.goals then
                    self:compress_goals()
                end
            else
                self.pos = self.goal
                self.goal = nil

                if self.goals and self.goals[1] then
                    self.goal = self.goals[1]
                    table.remove(self.goals, 1)
                end
                
                self.costume:set_pose("idle")

                if not self.goal then
                    self.events.goal()
                end
                
                self:compress_goals()
            end
        elseif type(self.goal) == "function" then
            self.costume:set_pose("idle")
        
            tasks.start({ self.goal, function() 
                if self.goals and self.goals[1] then
                    self.goal = self.goals[1]
                    table.remove(self.goals, 1)
                end
            end })
            self.goal = true
        end
    end
end
