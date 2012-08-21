SIZE = { x = 1280, y = 720 }

MOAISim.openWindow("Earnest Money", 1280, 720)

viewport = MOAIViewport.new()
viewport:setSize(SIZE.x, SIZE.y)
viewport:setScale(1280, -720)
viewport:setOffset(-1, 1)

mouse = { x = 0, y = 0, cursor = 5 }

require "assets/costumes/costumes"
require "assets/sheets/_layout"

local function keyCallback(key, down)
    if down and key == 27 then
        MOAISim.crash()
    end
end

local function pointerCallback(x, y)
    mouse.x = x
    mouse.y = y
    
    if mouse.prop then
        mouse.prop:setIndex(mouse.cursor + 1)
        mouse.prop:setLoc(x, y)
    end
end

local function hoverCallback()
    Sheet.hover(mouse.x, mouse.y)
    
    if mouse.prop then
        mouse.prop:setIndex(mouse.cursor + 1)
    end
end

local function clickCallback(down)
    --if down then
        Sheet.click(mouse.x, mouse.y, down)
    --end
end

local hoverTimer = Timer.new(1 / 60, hoverCallback)

MOAIInputMgr.device.pointer:setCallback(pointerCallback)
MOAIInputMgr.device.mouseLeft:setCallback(clickCallback)
MOAIInputMgr.device.keyboard:setCallback(keyCallback)
