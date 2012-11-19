require "classes/class"
require "classes/polygon"

newclass("Hotspot", function(id, cursor, name, interface, poly)
        return {
            id = id,
            cursor = cursor,
            name = name,
            interface = interface,
            polygon = poly,
            
            endpoint = nil,
            walkspot = nil
        }
    end
)

function Hotspot:hitTest(x, y)
    return self.polygon:hitTest(x, y)
end

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
