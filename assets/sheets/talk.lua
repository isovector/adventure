require "classes/sheet"
require "classes/labeler"

local sheet = Sheet.new("talk")

sheet:install()

--------------------------------------------------

local function showMessage(...)
    return sheet:getLabeler():addLabel(...)
end

local function hideMessage(label)
    return sheet:getLabeler():removeLabel(label)
end

game:add("showMessage", showMessage)
game:add("hideMessage", hideMessage)
