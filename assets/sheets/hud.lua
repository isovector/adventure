require "classes/game"
require "classes/sheet"
require "classes/timer"
require "classes/legacy/library"

local sheet = Sheet.new("hud")
sheet:install()

local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
local font = MOAIFont.new()
font:loadFromTTF('assets/static/arial-rounded.TTF', charcodes, 7.5, 163)

local hover_text = MOAITextBox.new()
hover_text:setFont(font)
hover_text:setTextSize(7.5, 163)
hover_text:setRect(15, 15, 150, 50)
hover_text:setAlignment(MOAITextBox.LEFT_JUSTIFY)
sheet:insertProp(hover_text)

local fps_text = MOAITextBox.new()
fps_text:setFont(font)
fps_text:setColor(1, 0, 0)
fps_text:setTextSize(7.5, 163)
fps_text:setRect(1115, 15, 1265, 50)
fps_text:setAlignment(MOAITextBox.RIGHT_JUSTIFY)
sheet:insertProp(fps_text)

local pos_text = MOAITextBox.new()
pos_text:setFont(font)
pos_text:setColor(1, 1, 1)
pos_text:setTextSize(7.5, 163)
pos_text:setRect(1115, 680, 1265, 705)
pos_text:setAlignment(MOAITextBox.RIGHT_JUSTIFY)
sheet:insertProp(pos_text)

local buffer_text = MOAITextBox.new()
buffer_text:setFont(font)
buffer_text:setColor(1, 1, 1)
buffer_text:setString("--NORMAL--")
buffer_text:setTextSize(7.5, 163)
buffer_text:setRect(15, 680, 150, 705)
buffer_text:setAlignment(MOAITextBox.LEFT_JUSTIFY)
sheet:insertProp(buffer_text)

local cursor_deck = MOAITileDeck2D.new()
cursor_deck:setTexture("assets/static/cursors.png")
cursor_deck:setSize(11, 1)
cursor_deck:setRect(-16, -16, 16, 16)

local cursor = MOAIProp2D.new()
cursor:setDeck(cursor_deck)
cursor:setLoc(640, 480)
sheet:insertProp(cursor)

local function setCursor(cur)
    cursor:setIndex(cur + 1)
end

local function setCursorPos(x, y)
    cursor:setLoc(x, y)
    
    pos_text:setString(x .. ", " .. y)
end

local function setHoverText(str)
    hover_text:setString(str)
end

local function updateBuffer(str)
    buffer_text:setString(str)
end

game.export({ setHoverText = setHoverText, setCursor = setCursor, setCursorPos = setCursorPos, updateBuffer = updateBuffer })

local function timerCallback()
    fps_text:setString(tostring(math.round(MOAISim.getPerformance())))
end

local timer = Timer.new(1, timerCallback)
