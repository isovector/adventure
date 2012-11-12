local function keyCallback(key, down)
    if not down then return end

    if key == 27 then
        vim:clear(true)
    elseif key == 13 then
        vim:send()
    elseif key == 8 then
        vim:backspace()
    else
        vim:addChar(string.char(key))
    end
    
    game.updateBuffer(vim:getBufferText())
end

--------------------------------------------------

local mouse = { x = 0, y = 0, down = false }
game.export("getMouse", function() return mouse.x, mouse.y end)
game.export("isMouseDown", function() return mouse.down end)

--------------------------------------------------

local function pointerCallback(x, y)
    mouse.x = x
    mouse.y = y
    game.setCursorPos(x, y)
end

local function hoverCallback()
    while true do
        Sheet.dispatchHover(mouse.x, mouse.y)
        
        Sheet.dispatchBeforeDraw()
        coroutine.yield()
        Sheet.dispatchAfterDraw()
    end
end

local function clickCallback(down)
    mouse.down = down
    Sheet.dispatchClick(mouse.x, mouse.y, down)
end

local function rClickCallback(down)
    Sheet.dispatchRClick(mouse.x, mouse.y, down)
end

local routine = MOAICoroutine.new()
routine:run(hoverCallback)

MOAIInputMgr.device.pointer:setCallback(pointerCallback)
MOAIInputMgr.device.mouseLeft:setCallback(clickCallback)
MOAIInputMgr.device.mouseRight:setCallback(rClickCallback)
MOAIInputMgr.device.keyboard:setCallback(keyCallback)

game.updateBuffer(vim:getBufferText())
