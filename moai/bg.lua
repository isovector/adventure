local viewport = viewport

bgLayer = MOAILayer2D.new()
bgLayer:setViewport(viewport)
MOAISim.pushRenderPass(bgLayer)

bgQuad = MOAIGfxQuad2D.new()
bgQuad:setTexture("../game/rooms/outside/art.png")
bgQuad:setRect(0, 0, SIZE.x, SIZE.y)
bgQuad:setUVRect(0, 0, 1, 1)

bgProp = MOAIProp2D.new()
bgProp:setDeck(bgQuad)
bgLayer:insertProp(bgProp)


local mouse = { x = 0, y = 0 }

local function pointerCallback(x, y)
    mouse.x = x
    mouse.y = y
end

local function clickCallback(down)
    if down then
        local x = mouse.x
        local y = mouse.y
    
        addVis(function()
            MOAIGfxDevice.setPenColor(0, 0, 1)
            MOAIDraw.fillRect(x - 8, y - 8, x + 8, y + 8)
        end)
    end
end

MOAIInputMgr.device.pointer:setCallback(pointerCallback)
MOAIInputMgr.device.mouseLeft:setCallback(clickCallback)