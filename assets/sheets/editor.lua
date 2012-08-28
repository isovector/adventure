require "classes/game"
require "classes/sheet"

local sheet = Sheet.new("editor")
sheet:install()
sheet:enable(false)

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
    -- Write out pathfinding
    local f = io.open(room.directory .. "/pathfinding.lua", "w")
    f:write("return {\n")
    for i = 1, #points, 2 do
        f:write("\t" .. points[i] ..  ", " .. points[i + 1] .. ",\n")
    end
    f:write("}\n")
    f:close()
    
    room:installPathing(points)
    
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

local function add_point()
    local x, y = game.getMouse()
    
    table.insert(points, x)
    table.insert(points, y)

    invalidate()
end

local function remove_point()
    table.remove(points, #points)
    table.remove(points, #points)
    
    invalidate()
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

vim:createMode("editor", 
    function(old) 
        if old == "normal" then sheet:enable(true) end 
    end, 
    
    function(new) 
        if new == "normal" then sheet:enable(false) end 
    end
)

vim:buf("normal",   "^E$",      function() vim:setMode("editor") end)
vim:buf("editor",   "^ZZ$",     save)
vim:buf("editor",   "^a$",      add_point)
vim:buf("editor",   "^x$",      remove_point)
vim:cmd("editor",   "p|lace",   place)
vim:cmd("editor",   "r|emove",  remove)
