require "classes/game"
require "classes/shader"
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

local shader = Shader.new("vertex", "recolor")
shader:applyTo(cursor)

local item_deck = MOAIGfxQuad2D.new()
item_deck:setRect(-32, -32, 32, 32)
item_deck:setUVRect(0, 0, 1, 1)

--------------------------------------------------

local dirty = true
local currentItem
local currentObject
local currentVerb

--------------------------------------------------

local function getCurrentItem()
    return currentItem
end

local function setHoverText(str)
    hover_text:setString(str)
end

local function updateNarration()
    if not dirty then
        return
    end
    
    dirty = false

    local item = currentItem and currentItem.name or nil
    local itemtags = currentItem and currentItem.tags or { }
    local type = currentObject and currentObject.__type or nil
    local objtags = currentObject and currentObject.tags or { }
    local name = currentObject and currentObject.name or nil
    
    local predicate = { 
        verb = currentVerb, 
        object = name, 
        item = item, 
        type = type, 
        unpack(objtags),
        unpack(itemtags)
    }
    
    setHoverText(game.getNarration(predicate))
end

local function setCurrentItem(item)
    if currentItem == item then return end

    currentItem = item
    
        
    dirty = true
    updateNarration()

    if not item then
        cursor:setDeck(cursor_deck)
        return
    end
    
    item_deck:setTexture(item.img)
    cursor:setDeck(item_deck)
end

local function setCurrentVerb(verb)
    if currentVerb == verb then return end

    currentVerb = verb
    
    dirty = true
    updateNarration()
end

local function setCurrentObject(obj)
    if currentObject == obj then return end

    if currentItem then
        if obj == nil then
            cursor.shader.fragment.strength = 0
        else
            cursor.shader.fragment.strength = 1
        end
    end
    
    currentObject = obj
    
    dirty = true
    updateNarration()
end

local function getCurrentObject(obj)
    return currentObject
end

local function setCursor(cur)
    cursor:setIndex(cur + 1)
end

local function setCursorPos(x, y)
    cursor:setLoc(x, y)
end

local function updateBuffer(str)
    buffer_text:setString(str)
end

game.export({ 
    getCurrentItem = getCurrentItem,
    setCurrentItem = setCurrentItem,
    getCurrentObject = getCurrentObject,
    setCurrentObject = setCurrentObject,
    setCurrentVerb = setCurrentVerb,
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
