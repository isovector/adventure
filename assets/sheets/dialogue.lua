require "classes/game"
require "classes/sheet"
require "classes/dialogue"
require "classes/labeler"

local sheet = Sheet.new("dialogue")

sheet:setClickAcceptor(Sheet.prop_acceptor)
sheet:setHoverAcceptor(Sheet.prop_acceptor)
sheet:install()
sheet:enable(false)

--------------------------------------------------

local topic
local options
local props = { }
local function showTopic(newtopic)
    topic = newtopic
    options = topic:getOptions()
    
    sheet:enable(true)
    
    local labeler = sheet:getLabeler()
    labeler:clearLabels()
    props = { }
    
    for i, option in ipairs(options) do
        local x = 25
        local y = 650 + (i - #options) * 26
    
        print(option.caption)
        local label = labeler:addLabel(option.caption, x, y)
        label:setRect(x, y, x + 600, y + 24)
        label:setAlignment(MOAITextBox.LEFT_JUSTIFY)
        label.option_id = option.id
        table.insert(props, label)
    end
end


game.export("showTopic", showTopic)

--------------------------------------------------

function sheet:onClick(prop, x, y, down)
    if not prop.option_id then
        return true
    end
    
    sheet:enable(false)
    topic:option(prop.option_id)

    return true
end

function sheet:onHover(prop, x, y)
    for _, p in ipairs(props) do
        p:setColor(1, 1, 1)
    end
    
    if prop.option_id then
        game.setCursor(5)
        prop:setColor(1, 0, 0)
    else
        game.setCursor(0)
    end
    
    return true
end
