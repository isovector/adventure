mrequire "src/game/hotspot"
mrequire "src/engine/sheet"
mrequire "src/engine/task"

import player from Adventure

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

game:add("setHotspots", setHotspots)
game:add("getHotspotAtXY", getHotspotAtXY)

--------------------------------------------------

local function handleDoors(object)
    local event = game.getEventCallback(object, "click")
    
    if event then
        event()
    elseif object.endpoint then
        Task.start(function()
            local actor = player
        
            if object.walkspot then
                local x, y = unpack(object.walkspot)
                actor:walkToAsync(x, y, function()
                    Room.change(object.endpoint.room)
                    actor:joinScene()
                    actor:teleport(object.endpoint.x, object.endpoint.y)
                end)
            end
        end)
    end
end

--------------------------------------------------

function sheet:onClick(prop, x, y, down)
    for _, hotspot in ipairs(hotspots) do
        if hotspot:hitTest(x, y) and hotspot.interface then
            game.interactWith(x, y, down, handleDoors)
            return true
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
