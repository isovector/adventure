MOAISim.openWindow("Earnest Money", 1280, 720)

viewport = MOAIViewport.new()
viewport:setSize(1280, 720)
viewport:setScale(1280, -720)
viewport:setOffset(-1, 1)

require "classes/timer"
require "assets/costumes/costumes"
require "assets/sheets/_layout"

local function keyCallback(key, down)
    if down and key == 27 then
        MOAISim.crash()
    end
end

local mouse = { x = 0, y = 0 }

local function pointerCallback(x, y)
    mouse.x = x
    mouse.y = y
    game.setCursorPos(x, y)
end

local function hoverCallback()
    Sheet.hover(mouse.x, mouse.y)
end

local function clickCallback(down)
    Sheet.click(mouse.x, mouse.y, down)
end

local hoverTimer = Timer.new(1 / 60, hoverCallback)

MOAIInputMgr.device.pointer:setCallback(pointerCallback)
MOAIInputMgr.device.mouseLeft:setCallback(clickCallback)
MOAIInputMgr.device.keyboard:setCallback(keyCallback)
