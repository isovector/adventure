require "classes/game"
require "classes/polygon"
require "classes/sheet"

local sheet = Sheet.new("editor")
sheet:install()
sheet:enable(false)

sheet:setHoverAcceptor(Sheet.all_acceptor)

local color = { 0, 1, 0 }
local poly = { }

local curroom = room


local function drawPolygon(poly)
    MOAIDraw.drawLine(poly.points)
    MOAIDraw.drawLine(poly.points[1], poly.points[2], poly.points[#poly.points - 1], poly.points[#poly.points])
end

local function onDraw()
    if room ~= curroom then
        curroom = room
        
        if room and room.astar then
            poly = Polygon.new(room.astar.polys)
        else
            poly = Polygon.new()
        end
    end

    MOAIGfxDevice.setPenColor(unpack(color))
    drawPolygon(poly)
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
    -- Write out pathfinding
    local f = io.open(room.directory .. "/pathfinding.lua", "w")
    local points = poly.points
    f:write("return {\n")
    for i = 1, #points, 2 do
        f:write("\t" .. points[i] ..  ", " .. points[i + 1] .. ",\n")
    end
    f:write("}\n")
    f:close()
    
    -- Write out actors
    f = io.open(room.directory .. "/actors.lua", "w")
    f:write("return function(room)\n")
    for key, entry in pairs(room.scene) do
        f:write("\troom:addActor(Actor.getActor(\"" .. key ..  "\"), " .. entry.x .. ", " .. entry.y .. ")\n")
    end
    f:write("end\n")
    f:close()
    
    color = { 0, 1, 0 }
end

local function invalidate()
    color = { 1, 0, 0 }
end

local function update_pathing()
    room:installPathing(poly.points)
end

local function add_point()
    local x, y = game.getMouse()
    
    poly:addPoint(x, y)

    invalidate()
    update_pathing()
end

local function remove_point()
    poly:removePoint()

    invalidate()
    update_pathing()
end

local function place(id)
    local actor = Actor.getActor(id)
    local x, y = game.getMouse()
    
    if actor then
        invalidate()
        room:addActor(actor, x, y)
    end
end

local function remove(id)
    local actor = Actor.getActor(id)
    
    if actor then
        invalidate()
        room:removeActor(actor)
    end
end

local function setPolygon(...)
    poly = Polygon.new(...)
end

vim:createMode("polygon",
    function(old)
    end,
    
    function(new)
        --poly = Polygon.new()
    end
)

vim:createMode("editor", 
    function(old) 
        if old == "normal" then sheet:enable(true) end 
    end, 
    
    function(new) 
        if new == "normal" then sheet:enable(false) end 
    end
)

vim:buf("normal",   "^E$",      function() vim:setMode("editor") end)
vim:buf("editor",   "^w$",      function() --[[setPolygon(room.astar.polys)]] vim:setMode("polygon") end)
vim:buf("editor",   "^ZZ$",     save)
vim:cmd("editor",   "desc|ribe", function() print(unpack(points)) end)
vim:cmd("editor",   "p|lace",   place)
vim:cmd("editor",   "r|emove",  remove)
vim:buf("polygon",   "^a$",      add_point)
vim:buf("polygon",   "^x$",      remove_point)
