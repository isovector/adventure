require "classes/game"
require "classes/costume"
require "classes/sheet"

local sheet = Sheet.new("foreground")

local santino = MOAIProp2D.new()
santino:setLoc(400, 400)
sheet:insertProp(santino)
costumes.santino:bind(santino)
costumes.santino:refresh_anim()

sheet:install()

sheet:allowHover(true)

function sheet:onHover(prop, x, y)
    game.setHoverText("hello")
    game.setCursor(5)

    return true
end
