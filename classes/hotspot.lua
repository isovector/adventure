require "classes/class"
local Shapes = require "classes/lib/HardonCollider/shapes"

newclass("Hotspot", function(id, cursor, name, ...)
        return {
            id = id,
            cursor = cursor,
            name = name,
            shape = Shapes.newPolygonShape(...)
        }
    end
)

function Hotspot:hitTest(x, y)
    return self.shape:contains(x, y)
end