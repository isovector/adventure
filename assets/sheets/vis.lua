require "classes/sheet"
require "classes/timer"

local viewport = viewport
local freq = 0.25

local vises = { }

local sheet = Sheet.new("visualization")
sheet:install()

local function onDraw()
    for _, entry in ipairs(vises) do
        entry.call()
    end
end

local scriptDeck = MOAIScriptDeck.new()
scriptDeck:setRect(0, 0, 1280, 720)
scriptDeck:setDrawCallback(onDraw)

local prop = MOAIProp2D.new()
prop:setDeck(scriptDeck)
sheet:insertProp(prop)

local function timerCallback()
    for key, entry in ipairs(vises) do
        if entry.time ~= "forever" then
            if entry.time < 0 then
                table.remove(vises, key)
            else
                entry.time = entry.time - freq
            end
        end
    end
end

local timer = Timer.new(freq, true, timerCallback)

local function addVis(call, time)
    table.insert(vises, 
        { 
            time = time or "forever",
            call = call
        })
end

game:add("addVisualization", addVis)
