local viewport = viewport
local freq = 0.25

local vises = { }

visLayer = MOAILayer2D.new()
visLayer:setViewport(viewport)
MOAISim.pushRenderPass(visLayer)

local function onDraw()
    for call in pairs(vises) do
        call()
    end
end

scriptDeck = MOAIScriptDeck.new()
scriptDeck:setRect(0, 0, SIZE.x, SIZE.y)
scriptDeck:setDrawCallback(onDraw)

visProp = MOAIProp2D.new()
visProp:setDeck(scriptDeck)
visLayer:insertProp(visProp)

local function callback()
    for call, time in pairs(vises) do
        if time ~= "forever" then
            if time < 0 then
                vises[call] = nil
            else
                vises[call] = time - freq
            end
        end
    end
end

timer = MOAITimer.new()
timer:setMode(MOAITimer.LOOP)
timer:setListener(MOAITimer.EVENT_TIMER_LOOP, callback)
timer:setSpan(freq)
timer:start()

function addVis(call, time)
    vises[call] = time or "forever"
end