SIZE = { x = 1280, y = 720 }

MOAISim.openWindow("Earnest Money", 1280, 720)

viewport = MOAIViewport.new()
viewport:setSize(1280, 720)
viewport:setScale(1280, -720)
viewport:setOffset(-1, 1)

dofile("sheet.lua")
dofile("bg.lua")
dofile("fg.lua")
dofile("vis.lua")
dofile("hud.lua")

local mouse = { x = 0, y = 0 }

local function keyCallback(key, down)
    if down and key == 27 then
        MOAISim.crash()
    end
end

local function pointerCallback(x, y)
    mouse.x = x
    mouse.y = y
    
    Sheet.hover(x, y)
end

local function clickCallback(down)
    if down then
        Sheet.click(mouse.x, mouse.y)
    end
end

MOAIInputMgr.device.pointer:setCallback(pointerCallback)
MOAIInputMgr.device.mouseLeft:setCallback(clickCallback)
MOAIInputMgr.device.keyboard:setCallback(keyCallback)
