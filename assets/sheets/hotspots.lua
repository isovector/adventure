require "classes/game"
require "classes/hotspot"
require "classes/sheet"

local sheet = Sheet.new("hotspots")

sheet:setClickAcceptor(Sheet.all_acceptor)
sheet:setHoverAcceptor(Sheet.all_acceptor)
sheet:needsDraw(false)
sheet:install()

--------------------------------------------------

local hotspots = { }
local function setHotspots(t)
    hotspots = t
end

local function getHotspotAtXY(x, y)
    for _, hotspot in ipairs(hotspots) do
        if hotspot:hitTest(x, y)  then
            return hotspot
        end
    end
end

game.export("setHotspots", setHotspots)
game.export("getHotspotAtXY", getHotspotAtXY)

--------------------------------------------------

function sheet:onClick(prop, x, y, down)
    for _, hotspot in ipairs(hotspots) do
        if hotspot:hitTest(x, y) and hotspot.interface then
            if down then
                game.startVerbCountdown(x, y, hotspot)
                return true
            end
        end
    end
    
    return false
end

function sheet:onHover(prop, x, y)
    for _, hotspot in ipairs(hotspots) do
        if hotspot:hitTest(x, y) and hotspot.interface then
            game.setCurrentObject(hotspot)
            game.setCursor(hotspot.cursor)
            return true
        end
    end
    
    return false
end
