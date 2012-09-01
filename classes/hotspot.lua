require "classes/class"
require "classes/polygon"

newclass("Hotspot", function(id, cursor, name, poly)
        return {
            id = id,
            cursor = cursor,
            name = name,
            polygon = poly
        }
    end
)

function Hotspot:hitTest(x, y)
    return self.polygon:hitTest(x, y)
end
