require "classes/class"

newclass("Labeler",
    function(layer, fontpath)
        local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
        local font = MOAIFont.new()
        font:loadFromTTF(fontpath, charcodes, 7.5, 163)
    
        local style = MOAITextStyle.new()
        style:setColor(1, 1, 1)
        style:setFont(font)
        style:setSize(7.5, 163)
        
        local self = {
            labels = { },
            style = style,
            count = 0,
            layer = layer
        }
        
        local scriptDeck = MOAIScriptDeck.new()
        scriptDeck:setRect(0, 0, 1280, 720)
        scriptDeck:setDrawCallback(function() self:draw() end)
        
        local scriptprop = MOAIProp2D.new()
        scriptprop:setDeck(scriptDeck)
        scriptprop:setPriority(999998)
        layer:insertProp(scriptprop)
        
        return self
    end
)

function Labeler:draw()
    for label in pairs(self.labels) do
        local x, y, w, h = label:getStringBounds(1, 100)
    
        MOAIGfxDevice.setPenColor(0, 0, 0)
        if w then
            MOAIDraw.fillRect(x - 3, y, w + 3, h - 3)
        end
    end
end

function Labeler:addLabel(str, x, y, r, ...)
    local label = MOAITextBox.new()
    label:setStyle(self.style)
    
    if r then
        label:setColor(r, ...)
    end
    
    label:setString(str)
    label:setRect(x - 100, y - 10, x + 100, y + 10)
    label:setAlignment(MOAITextBox.CENTER_JUSTIFY)
    label:setPriority(999999)
    
    self.labels[label] = label
    self.layer:insertProp(label)
    self.count = self.count + 1
    
    return label
end

function Labeler:removeLabel(label)
    if self.labels[label] then
        self.labels[label] = nil
        self.layer:removeProp(label)
        self.count = self.count - 1
    end
end

function Labeler:clearLabels()
    for label in pairs(self.labels) do
        self.layer:removeProp(label)
    end
    
    self.labels = { }
    self.count = 0
end

function Labeler:size()
    return self.count
end
