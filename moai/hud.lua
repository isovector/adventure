dofile("../scripts/library.lua")

local sheet = Sheet.new("hud")
sheet:pushRenderPass()

local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
local font = MOAIFont.new()
font:loadFromTTF('arial-rounded.TTF', charcodes, 7.5, 163)

textbox = MOAITextBox.new()
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
tileLib:setTexture("../game/resources/cursors.png")
tileLib:setSize(11, 1)
tileLib:setRect(-16, -16, 16, 16)

local prop = MOAIProp2D.new()
prop:setDeck(tileLib)
prop:setLoc(640, 480)
sheet:insertProp(prop)

mouse.prop = prop

local function timerCallback()
    fps:setString(tostring(math.round(MOAISim.getPerformance())))
end

local timer = MOAITimer.new()
timer:setMode(MOAITimer.LOOP)
timer:setListener(MOAITimer.EVENT_TIMER_LOOP, timerCallback)
timer:setSpan(1)
timer:start()
