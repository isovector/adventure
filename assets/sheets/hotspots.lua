require "classes/game"
require "classes/hotspot"
require "classes/sheet"

local hotspots = { }

local function setHotspots(t)
    hotspots = t
end

game.export("setHotspots", setHotspots)

local sheet = Sheet.new("hotspots")

sheet:needsDraw(false)
sheet:install()

sheet:setClickAcceptor(Sheet.all_acceptor)
sheet:setHoverAcceptor(Sheet.all_acceptor)

function sheet:onClick(prop, x, y)
    for _, hotspot in ipairs(hotspots) do
        if hotspot:hitTest(x, y) then
            return true
        end
    end
    
    return false
end

function sheet:onHover(prop, x, y)
    for _, hotspot in ipairs(hotspots) do
        if hotspot:hitTest(x, y) then
            game.setHoverText(hotspot.name)
            game.setCursor(hotspot.cursor)
            return true
        end
    end
    
    return false
end
