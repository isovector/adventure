require "classes/hotspot"
require "classes/sheet"

local hotspots = {
    stop = Hotspot.new("stop", 5, "Stop!", 
        546, 406, 
        572, 407, 
        585, 423, 
        586, 441, 
        576, 456, 
        549, 453, 
        536, 440, 
        538, 415
    )
}

local sheet = Sheet.new("hotspots")
sheet:pushRenderPass()

sheet:installHover(true)

function sheet:hoverCallback(x, y)
    for _, hotspot in pairs(hotspots) do
        if hotspot:hitTest(x, y) then
            textbox:setString(hotspot.name)
            mouse.cursor = hotspot.cursor
            return true
        end
    end
    
    return false
end
