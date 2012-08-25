require "classes/game"
require "classes/sheet"

local sheet = Sheet.new("background")
local quad = MOAIGfxQuad2D.new()
quad:setRect(0, 0, 1280, 720)
quad:setUVRect(0, 0, 1, 1)

local prop = MOAIProp2D.new()
prop:setDeck(quad)

sheet:insertProp(prop)
sheet:install()

sheet:allowClick(true)
sheet:allowHover(true)

local function setBackground(path)
    quad:setTexture(path)
end
game.export("setBackground", setBackground)


function sheet:onHover()
    game.setHoverText("")
    game.setCursor(0)
    return true
end

function sheet:onClick(prop, x, y, down)
    if not down then return true end
    
    Actor.getActor("santino"):setGoal(x, y)
    
    return true
end
