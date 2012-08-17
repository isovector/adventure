----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

MOAISim.openWindow ( "test", 320, 480 )

viewport = MOAIViewport.new ()
viewport:setSize ( 320, 480 )
viewport:setScale ( 320, -480 )

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )


local query = { x = 2, y = 8,  w = 2, h = 2 }

local map = 
    {
    { 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 },
    { 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 },
    { 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 1, 1, 1, 0, 0 },
    { 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1 }
    }
    
local SIZE_X = #map[1]
local SIZE_Y = #map
local WIDTH = 16
local HEIGHT = 16

    
local colors =
    { 
    { 0, 1, 0 },
    { 1, 0, 0 },
    { 0, 0, 1 },
    { 1, 0, 1 }
    }
    
function getRect(query)
    local x, y

    if query.w % 2 == 0 then
        x = query.x - query.w / 2 + 1
    else
        x = query.x - (query.w - 1) / 2
    end
    
    if query.h % 2 == 0 then
        y = query.y - query.h / 2 + 1
    else
        y = query.y - (query.h - 1) / 2
    end
    
    return { x = x, y = y, w = query.w, h = query.h }
end

function getNeighbors(query)
    local t = { }
    for j = 1, 3 do
        local dy = j - 2
        for i = 1, 3 do
            local dx = i - 2
            
            if not (dx == 0 and dy == 0) then
                -- clean this up
                local query = { x = query.x + dx, y = query.y + dy, w = query.w, h = query.h }
                
                if checkRect(query) then
                    table.insert(t, { x = query.x, y = query.y, w = query.w, h = query.h })
                end
            end
        end
    end

    return t
end

function checkRect(query)
    local rect = getRect(query)
    for y = 1, rect.h do
        for x = 1, rect.w do
            local x = rect.x + x
            local y = rect.y + y
        
            if (x < 1 or x > SIZE_X or y < 1 or y > SIZE_Y) or not (map[y][x] == 0) then
                return false
            end
        end
    end
    
    return true
end

function setRect(query, c)
    local rect = getRect(query)
    for y = 1, rect.h do
        for x = 1, rect.w do
            local x = rect.x + x
            local y = rect.y + y
        
            if not ((x < 1 or x > SIZE_X) or (y < 1 or y > SIZE_Y)) then
                map[y][x] = c
            end
        end
    end
end

for _, val in ipairs(getNeighbors(query)) do
    setRect(val, 2)
end

setRect(query, 3)

function onDraw ( index, xOff, yOff, xFlip, yFlip )
    for y = 1, SIZE_Y do
        for x = 1, SIZE_X do
            MOAIGfxDevice.setPenColor ( unpack(colors[map[y][x] + 1]) )
        
            local x = x - SIZE_X / 2
            local y = y - SIZE_Y / 2
            
            MOAIDraw.fillRect(x * WIDTH, y * HEIGHT, (x + 1) * WIDTH, (y + 1) * HEIGHT)
        end
    end
    
end

scriptDeck = MOAIScriptDeck.new ()
scriptDeck:setRect ( -64, -64, 64, 64 )
scriptDeck:setDrawCallback ( onDraw )

prop = MOAIProp2D.new ()
prop:setDeck ( scriptDeck )
layer:insertProp ( prop )
