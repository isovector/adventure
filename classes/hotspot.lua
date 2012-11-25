require "classes/class"
require "classes/polygon"

newclass("Hotspot", function(id, cursor, name, interface, poly, priority)
        priority = priority or 0

        return {
            id = id,
            cursor = cursor,
            name = name,
            interface = interface,
            polygon = poly,
            priority = priority,
            
            endpoint = nil,
            walkspot = nil
        }
    end
)

--------------------------------------------------

function Hotspot.hitTest(self, x, y)
    -- if called as a static method, the first param is a table to search
    if type(self) == "table" then
        local best = nil
        local bestScore = -999999
        for i, hotspot in ipairs(self) do
            if hotspot:hitTest(x, y) and hotspot.priority > bestScore then
                bestScore = hotspot.priority
                best = hotspot
            end
        end
        
        return best
    end

    return self.polygon:hitTest(x, y)
end

--------------------------------------------------

function Hotspot:link(roomId, x, y)
    self.endpoint = {
        room = roomId,
        x = x,
        y = y
    }
end

function Hotspot:setWalkspot(x, y)
    self.walkspot = { x, y }
end
