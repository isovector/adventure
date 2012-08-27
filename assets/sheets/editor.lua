require "classes/game"
require "classes/sheet"

local sheet = Sheet.new("editor")
sheet:install()
sheet:enable(false)

sheet:setClickAcceptor(Sheet.all_acceptor)
sheet:setRClickAcceptor(Sheet.all_acceptor)
sheet:setHoverAcceptor(Sheet.all_acceptor)

local color = { 0, 1, 0 }
local points = { }

local function onDraw()
    MOAIGfxDevice.setPenColor(unpack(color))
    MOAIDraw.drawLine(points)
    MOAIDraw.drawLine(points[1], points[2], points[#points - 1], points[#points])
end
    local scriptDeck = MOAIScriptDeck.new()
    scriptDeck:setRect(0, 0, 1280, 720)
    scriptDeck:setDrawCallback(onDraw)
    local prop = MOAIProp2D.new()
    prop:setDeck(scriptDeck)
    sheet:insertProp(prop)


function sheet:onHover()
    game.setCursor(10)

    return true
end

function sheet:onClick(prop, x, y, down)
    if not down then return true end

    table.insert(points, x)
    table.insert(points, y)

    return true
end

function sheet:onRClick(prop, x, y, down)
    table.remove(points, #points)
    table.remove(points, #points)
    
    return true
end
