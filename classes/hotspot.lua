require "classes/class"
require "classes/polygon"

newclass("Hotspot", function(id, cursor, name, interface, poly)
        return {
            id = id,
            cursor = cursor,
            name = name,
            interface = interface,
            polygon = poly
        }
    end
)

function Hotspot:hitTest(x, y)
    return self.polygon:hitTest(x, y)
end
