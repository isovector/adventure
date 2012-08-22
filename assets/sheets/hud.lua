require "classes/game"
require "classes/sheet"
require "classes/timer"
require "classes/legacy/library"

local sheet = Sheet.new("hud")
sheet:install()

local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
local font = MOAIFont.new()
font:loadFromTTF('assets/static/arial-rounded.TTF', charcodes, 7.5, 163)

local textbox = MOAITextBox.new()
textbox:setFont(font)
textbox:setTextSize(7.5, 163)
textbox:setRect(15, 15, 150, 50)
textbox:setAlignment(MOAITextBox.LEFT_JUSTIFY)
sheet:insertProp(textbox)

local fps = MOAITextBox.new()
fps:setFont(font)
fps:setColor(1, 0, 0)
fps:setTextSize(7.5, 163)
fps:setRect(1115, 15, 1265, 50)
fps:setAlignment(MOAITextBox.RIGHT_JUSTIFY)
sheet:insertProp(fps)

local tileLib = MOAITileDeck2D.new()
tileLib:setTexture("assets/static/cursors.png")
tileLib:setSize(11, 1)
tileLib:setRect(-16, -16, 16, 16)

local prop = MOAIProp2D.new()
prop:setDeck(tileLib)
prop:setLoc(640, 480)
sheet:insertProp(prop)

local function setCursor(cur)
    prop:setIndex(cur + 1)
end

local function setCursorPos(x, y)
    prop:setLoc(x, y)
end

local function setHoverText(str)
    textbox:setString(str)
end

game.export({ setHoverText = setHoverText, setCursor = setCursor, setCursorPos = setCursorPos })

local function timerCallback()
    fps:setString(tostring(math.round(MOAISim.getPerformance())))
end

local timer = Timer.new(1, timerCallback)
