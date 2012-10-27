require "classes/game"
require "classes/sheet"
require "classes/timer"

local sheet = Sheet.new("hud")
sheet:install()

--------------------------------------------------

local labeler = sheet:getLabeler()

local hover_text = labeler:addLabel("", 0, 0)
hover_text:setRect(15, 15, 500, 50)
hover_text:setAlignment(MOAITextBox.LEFT_JUSTIFY)

local fps_text = labeler:addLabel("", 0, 0)
fps_text:setRect(1115, 15, 1265, 50)
fps_text:setAlignment(MOAITextBox.RIGHT_JUSTIFY)

local buffer_text = labeler:addLabel("-- NORMAL --", 0, 0)
buffer_text:setRect(15, 680, 1100, 705)
buffer_text:setAlignment(MOAITextBox.LEFT_JUSTIFY)

local cursor_deck = MOAITileDeck2D.new()
cursor_deck:setTexture("assets/static/cursors.png")
cursor_deck:setSize(11, 1)
cursor_deck:setRect(-16, 16, 16, -16)

local cursor = MOAIProp2D.new()
cursor:setDeck(cursor_deck)
cursor:setLoc(640, 480)
sheet:insertProp(cursor)

local item_deck = MOAIGfxQuad2D.new()
item_deck:setRect(-32, -32, 32, 32)
item_deck:setUVRect(0, 0, 1, 1)

--------------------------------------------------

local currentItem
local currentObject
local currentVerb

--------------------------------------------------

local function updateHoverText()
    local str = ""
    
    if currentItem then
        str = currentItem.desc
        str = str:gsub("{v}", currentItem.name)
        str = str:gsub("{o}", currentObject or "...")
    end
end

--------------------------------------------------

local function getCurrentItem()
    return currentItem
end

local function setCurrentItem(item)
    currentItem = item

    if nil then
        cursor:setDeck(cursor_deck)
        return
    end
    
    item_deck:setTexture(item.img)
    cursor:setDeck(item_deck)
end

local function setCurrentVerb(verb)
end

local function setCurrentObject(name)
    currentObject = name
    
    hover_text:setString()
end

local function setCursor(cur)
    cursor:setIndex(cur + 1)
end

local function setCursorPos(x, y)
    cursor:setLoc(x, y)
end

local function setHoverText(str)
    hover_text:setString(str)
end

local function updateBuffer(str)
    buffer_text:setString(str)
end

game.export({ 
    getCurrentItem = getCurrentItem,
    setCurrentItem = setCurrentItem,
    setHoverText = setHoverText, 
    setCursor = setCursor, 
    setCursorPos = setCursorPos, 
    updateBuffer = updateBuffer 
})

--------------------------------------------------

local function timerCallback()
    fps_text:setString(string.format("%.1f", math.floor(MOAISim.getPerformance() * 10 + 0.5) / 10))
end

Timer.new(1, true, timerCallback)
