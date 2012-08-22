require "classes/game"
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

local function setHotspots(t)
    hotspots = t
end

game.export("setHotspots", setHotspots)

local sheet = Sheet.new("hotspots")

sheet:allowHover(true)
sheet:allowGraphics(false)
sheet:install()

function sheet:hoverCallback(x, y)
    for _, hotspot in pairs(hotspots) do
        if hotspot:hitTest(x, y) then
            game.setHoverText(hotspot.name)
            game.setCursor(hotspot.cursor)
            return true
        end
    end
    
    return false
end
