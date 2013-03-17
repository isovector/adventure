--- A Sheet component that provides arbitrary text-writing
-- services.
-- @see Sheet:getLabeler

mrequire "src/class"

--- The Labeler class.
-- Constructor signature is (layer, fontpath).
-- @param fontpath Deprecated. To be removed.
-- @newclass Hotspot
newclass("Labeler",
    function(layer, fontpath)
        local self = {
            labels = { },
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

--- Internal method called to draw the text buffers.
function Labeler:draw()
    for label in pairs(self.labels) do
        local x, y, w, h = label:getStringBounds(1, 100)
    
        MOAIGfxDevice.setPenColor(0, 0, 0)
        if w then
            MOAIDraw.fillRect(x - 3, y, w + 3, h - 3)
        end
    end
end

--- Adds a text buffer to the label layer.
-- @param str The string to write
-- @param x x
-- @param y y
-- @param r [optional] The red color component
-- @param ... [optional] The green and blue color components
-- @return A handle to the new label.
-- @see Labeler:removeLabel
function Labeler:addLabel(str, x, y, r, ...)
    local label = MOAITextBox.new()

    label:setTextSize(14)
    label:setFont(font)
    
    if r then
        label:setColor(r, ...)
    end
    
    label:setString(str)
    label:setPriority(999999)
    
    local w = (#str * 8) / 2
    if x - w < 0 then
        label:setRect(10, y - 10, x + 800, y + 10)
        label:setAlignment(MOAITextBox.LEFT_JUSTIFY)
    elseif x + w > 1280 then
        label:setRect(x - 800, y - 10, 1270, y + 10)
        label:setAlignment(MOAITextBox.RIGHT_JUSTIFY)
    else
        label:setRect(x - 400, y - 10, x + 400, y + 10)
        label:setAlignment(MOAITextBox.CENTER_JUSTIFY)
    end
    
    self.labels[label] = label
    self.layer:insertProp(label)
    self.count = self.count + 1
    
    return label
end

--- Removes a previously added label.
-- @param label The label handle returned by Labeler:addLabel.
function Labeler:removeLabel(label)
    if self.labels[label] then
        self.labels[label] = nil
        self.layer:removeProp(label)
        self.count = self.count - 1
    end
end

--- Removes all associated labels.
function Labeler:clearLabels()
    for label in pairs(self.labels) do
        self.layer:removeProp(label)
    end
    
    self.labels = { }
    self.count = 0
end

--- The number of labels currently being drawn.
-- @return size
function Labeler:size()
    return self.count
end
