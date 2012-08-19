local sheet = Sheet.new("hud")
local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
local font = MOAIFont.new()
font:loadFromTTF('arial-rounded.TTF', charcodes, 7.5, 163)

textbox = MOAITextBox.new()
textbox:setFont(font)
textbox:setTextSize(7.5, 163)
textbox:setRect(15, 15, 150, 50)
textbox:setAlignment(MOAITextBox.LEFT_JUSTIFY)
sheet:insertProp(textbox)

sheet:pushRenderPass()