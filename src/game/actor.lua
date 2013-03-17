--- actors are game objects. They can move, animate, and talk.
-- actors are usually created via the 2-load-actors.lua service,
-- which loads them from /game/actors/

mrequire "src/class"
require "src/game/dialogue"
mrequire "src/game/item"
mrequire "src/engine/task"

--- A global table containing id => Actor
import actors, room from Adventure
actors = { }

--- The Actor class.
-- Constructor signature is (id, name, costume, color).
-- @newclass Actor
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
            
            defaultScale = 1,
            
            action = nil,
            onGoal = nil,
            pressing = { },
            
            hitHotspot = nil
        }
        
        actors[id] = actor
        
        return actor
    end
)

--- Gets an actor by id.
-- This is more OO than directly indexing the actors table
-- @param id
-- @return An Actor registered by id
function Actor.getActor(id)
    return actors[id]
end

--- Gets the location of an Actor in world space.
-- @return x in world space
-- @return y in world space
function Actor:location() 
    return self.prop:getLoc()
end

--- Wrapper to get the prop scaling of the Actor.
-- This will crash if the Actor is not in the scene
function Actor:scale()
   return self.prop:getScl()
end

--- Sets the perspective size.
-- The given scale will be multiplied by the defaultScale
-- @param scale
function Actor:setScale(scale)
    self.prop:setScl(scale * self.defaultScale, scale * self.defaultScale)
end

--- Determines if a ray at (x, y) will hit the actor.
-- @return true IF the costume is hit but there is no hotspot underneath
-- @return Hotspot IF the costume is hit and a registerd hotspot
function Actor:hitTest(x, y)
    local hs = self.costume:hitTest(x, y, self:scale())
    
    if hs == true or not hs then
        self.hitHotspot = nil
    else
        hs.proxy = self
        self.hitHotspot = hs
    end
    
    return hs
end

--- Creates a prop and a game loop for an Actor.
-- This should probably never be called by user code
function Actor:joinScene()
    local prop = game.makeProp(tostring(self))
    prop.actor = self
    
    self.prop = prop
    self.costume:setProp(prop)
    self.costume:refresh()
    
    self:setScale(1)
    
    if not self.loop then
        self.loop = MOAIThread.new()
        self.loop:run(self.mainLoop, self)
    end
end

--- Destroys a prop and the game loop.
-- This should probably never be called by user code
function Actor:leaveScene()
    self.prop.actor = nil
    game.destroyProp(tostring(self))
    self.prop = nil
    self.stop = true
end

--- Instantly moves the Actor to (x, y).
function Actor:teleport(x, y)
    if self.prop then
        self.prop:setLoc(x, y)
        self.prop:setPriority(y)
        self:setScale(room.perspective[y])
    end
end

--- Instant moves the Actor by (x, y) relative to her current location.
function Actor:teleportRel(x, y)
    local sx, sy = self:location()
    self:teleport(sx + x, sy + y)
end

--- Paths an Actor to (x, y) without blocking the thread.
-- @param onGoal A callback to perform when she arrives
function Actor:walkToAsync(x, y, onGoal)
    if self.action then
        self.action:stop()
    end

    self.stop = true
    self.goal = { x, y }
    self.onGoal = onGoal
end

--- Gives an item by id to the Actor.
-- @param id
function Actor:giveItem(id)
    self.inventory[id] = Item.getItem(id)
end

--- Take an item by id away.
-- @param id
function Actor:removeItem(id)
    self.inventory[id] = nil
end

--- Does the Actor have an item by id?
-- @param id
-- @return whether or not the Actor has any Item:id
function Actor:hasItem(id)
    return self.inventory[id]
end

--- Display a text bubble above the Actor's head.
-- This will block the thread.
-- @param msg
function Actor:say(msg)
    local x, y = self:location()

    self.costume:setPose("talk")
    
    local label = game.showMessage(msg, x, y, unpack(self.color))
    Task.sleep(Dialogue.time(msg))
    game.hideMessage(label)
    
    self.costume:setPose("idle")
end

--- Cancels an asynchronous walk task.
function Actor:stopWalking()
    self.stop = true
    
    if self.action then
        self.action:stop()
    end
end

--- Synchronously walk to (x, y).
-- This will block the thread
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

--- Internal pathfollowing routine.
-- This should never be called by user code.
-- Also handles hotspot pressing and unpressing.
function Actor:moveToXY(x, y)
    if self.prop and not self.stop then
        local sx, sy = self:location()
    
        local dx, dy = x - sx, y - sy
        local dist = math.sqrt(dx * dx + dy * dy)
        
        self.costume:setDirection({ dx, dy })
    
        self.action = self.prop:moveLoc(dx, dy, dist / self.speed, MOAIEaseType.LINEAR)
        
        while self.action and self.action:isBusy() do
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
            self:setScale(room.perspective[y])
        
            coroutine.yield(0)
        end
        
        self.action = nil
    end
end

--- Internal thread procedure.
-- This should never be called by user code.
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

--- Convince an actor to exit the room by the id of a door.
-- @param id
function Actor:exitRoomByDoor(id)
    local door = room:getHotspotById(id)
    if door and door.walkspot then
        local x, y = unpack(door.walkspot)
        self:walkTo(x, y)
        room:removeActor(self)
    end
end
