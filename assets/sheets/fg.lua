require "classes/actor"
require "classes/game"
require "classes/costume"
require "classes/sheet"

local sheet = Sheet.new("foreground")

local function makeProp()
    local prop = MOAIProp2D.new()
    sheet:insertProp(prop)
    return prop
end

local function destroyProp(prop)
    sheet:removeProp(prop)
end

game.export("makeProp", makeProp)
game.export("destroyProp", destroyProp)

sheet:install()

sheet:allowHover(true)
function sheet:onHover(prop, x, y)
    if prop.actor then
        game.setHoverText(prop.actor.name)
    else
        game.setHoverText("Unknown")
    end
    
    game.setCursor(5)

    return true
end
