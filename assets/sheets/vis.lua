require "classes/sheet"
require "classes/timer"

local viewport = viewport
local freq = 0.25

local vises = { }

local sheet = Sheet.new("visualization")
sheet:pushRenderPass()

local function onDraw()
    for call in pairs(vises) do
        call()
    end
end

local scriptDeck = MOAIScriptDeck.new()
scriptDeck:setRect(0, 0, SIZE.x, SIZE.y)
scriptDeck:setDrawCallback(onDraw)

local prop = MOAIProp2D.new()
prop:setDeck(scriptDeck)
sheet:insertProp(prop)

local function timerCallback()
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

local timer = Timer.new(freq, timerCallback)

function addVis(call, time)
    vises[call] = time or "forever"
end