require "classes/game"
require "classes/hotspot"
require "classes/sheet"

local hotspots = { }

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
