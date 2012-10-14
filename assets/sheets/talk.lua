require "classes/game"
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

game.export("showMessage", showMessage)
game.export("hideMessage", hideMessage)
