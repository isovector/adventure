require "classes/sheet"
Shapes = require "classes/lib/HardonCollider/shapes"

local poly = Shapes.newPolygonShape(546, 406, 572, 407, 585, 423, 586, 441, 576, 456, 549, 453, 536, 440, 538, 415)


local sheet = Sheet.new("hotspots")
sheet:pushRenderPass()

sheet:installHover(true)

function sheet:hoverCallback(x, y)
    if poly:contains(x, y) then
        textbox:setString("Stop!")
        mouse.cursor = 5
        return true
    end
    
    return false
end
