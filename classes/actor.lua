require "classes/class"

local actors = { }
newclass("Actor", 
    function(id, name, costume)
        local actor = {
            id = id,
            name = name,
            costume = costume,
            speed = 150,
            inventory = { },
            goal = nil,
            prop = nil,
            loop = nil,
            stop = false
        }
        
        actors[id] = actor
        
        return actor
    end
)

function Actor.getActor(id)
    return actors[id]
end

function Actor:location() 
    return self.prop:getLoc()
end

function Actor:joinScene()
    local prop = game.makeProp()
    --prop:setLoc(0, 0)
    prop.actor = self
    
    self.prop = prop
    self.costume:setProp(prop)
    self.costume:refresh_anim()
    
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
    end
end

function Actor:teleportRel(x, y)
    local sx, sy = self:location()
    self:teleport(sx + x, sy + y)
end

function Actor:setGoal(x, y)
    self.stop = true
    self.goal = { x, y }
end

function Actor:walkTo(x, y)
    local sx, sy = self:location()
    local path = room:getPath(sx, sy, x, y, 1, 1)
    
    local has_path = #path ~= 0
    
    if has_path then
        self.costume:setProp(self.prop)
        self.costume:setPose("walk")
    end
    
    while #path ~= 0 do
        local goal = path[1]
        table.remove(path, 1)
        self:moveToXY(unpack(goal))
        
        if self.stop then path = { } end
    end
    
    if has_path then
        self.costume:setProp(self.prop)
        self.costume:setPose("idle")
    end
end

function Actor:moveToXY(x, y)
    if self.prop and not self.stop then
        local sx, sy = self:location()
    
        local dx, dy = x - sx, y - sy
        local dist = math.sqrt(dx * dx + dy * dy)
        
        self.costume:setProp(self.prop)
        self.costume:setDirection({ dx, dy })
    
        MOAIThread.blockOnAction(self.prop:moveLoc(dx, dy, dist / self.speed, MOAIEaseType.LINEAR))
    end
end

function Actor:mainLoop()
    while self.prop do
        coroutine.yield()
        
        local _, y = self:location()
        self.prop:setPriority(y)
    
        if self.goal then
            local goal = self.goal
            self.goal = nil
            self.stop = false
            self:walkTo(unpack(goal))
        end
    end
    
    self.loop = nil
end
