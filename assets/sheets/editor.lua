require "classes/game"
require "classes/polygon"
require "classes/sheet"

local sheet = Sheet.new("editor")
sheet:install()
sheet:enable(false)

sheet:setHoverAcceptor(Sheet.all_acceptor)

local color = { 0, 1, 0 }
local poly = { }
local polies = { }
local walking = { }

local curroom = room


local function showLabels()
    local labeler = sheet:getLabeler()
    
    if labeler:size() ~= 0 then return end
    
    for i = 1, #polies do
        local x, y = polies[i].points[1], polies[i].points[2]
        
        local str = tostring(i - 1)
        if i == 1 then
            str = "w"
        end
        
        labeler:addLabel(str, x, y, 0, 1, 0)
    end
end

local function hideLabels()
    sheet:getLabeler():clearLabels()
end

local function reloadRoom()
    if room and room.astar then
        walking = Polygon.new(room.astar.polys)
    else
        walking = Polygon.new()
    end

    table.insert(polies, walking)
    poly = walking
    
    for _, hs in pairs(room.hotspots) do
        table.insert(polies, hs.polygon)
    end
end


local function drawPolygon(poly)
    MOAIDraw.drawLine(poly.points)
    MOAIDraw.drawLine(poly.points[1], poly.points[2], poly.points[#poly.points - 1], poly.points[#poly.points])
end

local function onDraw()
    if room ~= curroom then
        reloadRoom()
        curroom = room
    end
    
    for _, p in ipairs(polies) do
        if p == poly then
            MOAIGfxDevice.setPenColor(unpack(color))
        else
            MOAIGfxDevice.setPenColor(0, 0, 1)
        end
        
        drawPolygon(p)
    end
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

local function write_points(f, points, prefix)
    prefix = prefix or "\t"

    for i = 1, #points, 2 do
        f:write(prefix .. points[i] ..  ", " .. points[i + 1] .. ",\n")
    end
end

local function save()
    -- Write out pathfinding
    local f = io.open(room.directory .. "/pathfinding.lua", "w")
    local points = walking.points
    f:write("return {\n")
        write_points(f, points)
    f:write("}\n")
    f:close()
    
    f = io.open(room.directory .. "/hotspots.lua", "w")
    f:write("return function(room)\n")
    
    for _, hotspot in pairs(room.hotspots) do
        f:write("\troom:addHotspot(Hotspot.new(\"" .. hotspot.id .. "\", " .. hotspot.cursor .. ", \"" .. hotspot.name .. "\", Polygon.new({\n")
        write_points(f, hotspot.polygon.points, "\t\t")
        f:write("\t})))\n")
    end
    
    f:write("end\n")
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
    --color = { 1, 0, 0 }
end

local function update_pathing()
    if poly == walking and poly:size() >= 3 then
        room:installPathing(poly.points)
    end
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

vim:cmd("editor",   "p|lace",
                                function(id)
                                    local actor = Actor.getActor(id)
                                    local x, y = game.getMouse()
                                    
                                    if actor then
                                        invalidate()
                                        room:addActor(actor, x, y)
                                    end
                                end)
    
vim:cmd("editor",   "r|emove",  function(id)
                                    local actor = Actor.getActor(id)
                                    
                                    if actor then
                                        invalidate()
                                        room:removeActor(actor)
                                    end
                                end)

-- this will fail when working with real hotspots
local newname = 1
vim:buf("editor",   "^ah$", 
                                function()
                                    local hotspot = Hotspot.new("new" .. newname, 5, "New Hotspot", Polygon.new())
                                    newname = newname + 1
                                    
                                    poly = hotspot.polygon
                                    table.insert(polies, poly)
                                    
                                    room:addHotspot(hotspot)
                                    vim:setMode("polygon")
                                end)

vim:buf("editor",   "^e",       function()
                                    showLabels()
                                    vim:addChangeCallback(hideLabels)
                                end)
    
vim:buf("editor",   "^ew$",
                                function()
                                    poly = polies[1]
                                    vim:setMode("polygon")
                                end)
    
vim:buf("editor",   "^e[0-9]+",
                                function(input)
                                    input = tonumber(input:sub(2)) + 1
                                    if polies[input] then
                                        poly = polies[input]
                                        vim:setMode("polygon")
                                        vim:clear()
                                    end
                                end)

vim:buf("polygon",   "^a$", 
                                function()
                                    local x, y = game.getMouse()
                                    
                                    poly:addPoint(x, y)

                                    invalidate()
                                    update_pathing()
                                end)
    
vim:buf("polygon",   "^x$",
                                function()
                                    poly:removePoint()

                                    invalidate()
                                    update_pathing()
                                end)
