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

local curroom = room


local function onDraw()
    if room ~= curroom then
        curroom = room
        
        if room and room.astar then
            points = room.astar.polys
        else
            points = { }
        end
    end

    MOAIGfxDevice.setPenColor(unpack(color))
    MOAIDraw.drawLine(points)
    MOAIDraw.drawLine(points[1], points[2], points[#points - 1], points[#points])
end
    local scriptDeck = MOAIScriptDeck.new()
    scriptDeck:setRect(0, 0, 1280, 720)
    scriptDeck:setDrawCallback(onDraw)
    local scriptprop = MOAIProp2D.new()
    scriptprop:setDeck(scriptDeck)
    sheet:insertProp(scriptprop)


function sheet:onHover(prop)
    --if not prop or prop == scriptprop then
        game.setCursor(10)
    --[[else
        game.setCursor(5)
    end]]

    return true
end

local function save()
    local f = io.open(room.directory .. "/pathfinding.lua", "w")

    f:write("return {\n")
    for i = 1, #points, 2 do
        f:write("\t" .. points[i] ..  ", " .. points[i + 1] .. ",\n")
    end
    f:write("}\n")
    
    f:close()
end

function sheet:onClick(prop, x, y, down)
    if not down then return true end
    
    if prop == scriptprop then
        table.insert(points, x)
        table.insert(points, y)
    end

    return true
end

function sheet:onRClick(prop, x, y, down)
    if not down then return true end

    table.remove(points, #points)
    table.remove(points, #points)
    
    return true
end

vim:createMode("editor", function() sheet:enable(true) end, function() sheet:enable(false) end)

vim:buf("", "^E$", function() vim:setMode("editor") end)
vim:buf("editor", "^ZZ$", save)
