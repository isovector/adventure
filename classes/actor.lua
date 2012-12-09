mrequire "classes/class"
mrequire "classes/dialogue"
mrequire "classes/item"
mrequire "classes/task"

Actors = { }
newclass("Actor", 
    function(id, name, costume, color)
        local actor = {
            id = id,
            name = name,
            costume = CostumeController.new(costume),
            speed = 150,
            inventory = { },
            color = color or { 1, 0, 1 },
            goal = nil,
            prop = nil,
            loop = nil,
            stop = false,
            
            action = nil,
            onGoal = nil,
            pressing = { },
            
            hitHotspot = nil
        }
        
        record /Actors, id = actor
        Actors[id] = actor
        
        return actor
    end
)

function Actor.getActor(id)
    return Actors[id]
end

function Actor:location() 
    return self.prop:getLoc()
end

function Actor:hitTest(x, y)
    local hs = self.costume:hitTest(x, y)
    
    if hs == true or not hs then
        self.hitHotspot = nil
    else
        hs.proxy = self
        self.hitHotspot = hs
    end
    
    return hs
end

function Actor:joinScene()
    local prop = game.makeProp()
    prop.actor = self
    
    self.prop = prop
    self.costume:setProp(prop)
    self.costume:refresh()
    
    if not self.loop then
        self.loop = MOAIThread.new()
        self.loop:run(self.mainLoop, self)
    end
end

function Actor:leaveScene()
    self.prop.actor = nil
    game.destroyProp(self.prop)
    self.prop = nil
    self.stop = true
end

function Actor:teleport(x, y)
    if self.prop then
        self.prop:setLoc(x, y)
        self.prop:setPriority(y)
    end
end

function Actor:teleportRel(x, y)
    local sx, sy = self:location()
    self:teleport(sx + x, sy + y)
end

function Actor:walkToAsync(x, y, onGoal)
    if self.action then
        self.action:stop()
    end

    self.stop = true
    self.goal = { x, y }
    self.onGoal = onGoal
end

function Actor:giveItem(id)
    self.inventory[id] = Item.getItem(id)
end

function Actor:removeItem(id)
    self.inventory[id] = nil
end

function Actor:hasItem(id)
    return self.inventory[id]
end

function Actor:say(msg)
    local x, y = self:location()

    self.costume:setPose("talk")
    
    local label = game.showMessage(msg, x, y, unpack(self.color))
    Task.sleep(Dialogue.time(msg))
    game.hideMessage(label)
    
    self.costume:setPose("idle")
end

function Actor:stopWalking()
    self.stop = true
    
    if self.action then
        self.action:stop()
    end
end

function Actor:walkTo(x, y)
    local sx, sy = self:location()
    local path = room:getPath(sx, sy, x, y, 1, 1)
    
    local has_path = #path ~= 0
    
    if has_path then
        self.costume:setPose("walk")
    end
    
    while #path ~= 0 do
        local goal = path[1]
        table.remove(path, 1)
        self:moveToXY(unpack(goal))
        
        if self.stop then path = { } end
    end
    
    if has_path then
        self.costume:setPose("idle")
    end
end

function Actor:moveToXY(x, y)
    if self.prop and not self.stop then
        local sx, sy = self:location()
    
        local dx, dy = x - sx, y - sy
        local dist = math.sqrt(dx * dx + dy * dy)
        
        self.costume:setDirection({ dx, dy })
    
        self.action = self.prop:moveLoc(dx, dy, dist / self.speed, MOAIEaseType.LINEAR)
        
        while self.action:isBusy() do
            sx, sy = self:location()
        
            -- do unpressing
            for hotspot in pairs(self.pressing) do
                if not hotspot:hitTest(sx, sy) then
                    local events = room.events[hotspot.id]
                    if events and events.unpress then
                        start(events.unpress, self)
                    end
                    
                    self.pressing[hotspot] = nil
                end
            end
            
            -- do pressing
            local hotspot = game.getHotspotAtXY(sx, sy)
            if hotspot and not self.pressing[hotspot] then
                local events = room.events[hotspot.id]
                if events and events.press then
                    start(events.press, self)
                end
                
                self.pressing[hotspot] = true
            end
            
            self.prop:setPriority(sy)
        
            coroutine.yield(0)
        end
        
        self.action = nil
    end
end

function Actor:mainLoop()
    while self.prop do
        local _, y = self:location()
        
    
        if self.goal then
            local goal = self.goal
            self.goal = nil
            self.stop = false
            self:walkTo(unpack(goal))
            
            if not self.stop and self.onGoal then
                self:onGoal()
                self.onGoal = nil
            end
        end
        
        coroutine.yield()
    end
    
    self.loop = nil
end
