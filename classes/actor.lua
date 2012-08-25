require "classes/class"

local actors = { }
newclass("Actor", 
    function(id, name, costume)
        local actor = {
            id = id,
            name = name,
            costume = costume,
            location = { x = 0, y = 0 },
            inventory = { },
            prop = nil
        }
        
        actors[id] = actor
        
        return actor
    end
)

function Actor.getActor(id)
    return actors[id]
end

function Actor:joinScene()
    local prop = game.makeProp()
    prop:setLoc(self.location.x, self.location.y)
    prop.actor = self
    
    self.prop = prop
    self.costume:setProp(prop)
    self.costume:refresh_anim()
end

function Actor:leaveScene()
    self.prop.actor = nil
    game.destroyProp(self.prop)
    self.prop = nil
end

function Actor:move(x, y)
    self.location = { x = x, y = y }
    
    if self.prop then
        self.prop:setLoc(x, y)
    end
end

function Actor:moveRel(x, y)
    self:move(location.x + x, location.y + y)
end
