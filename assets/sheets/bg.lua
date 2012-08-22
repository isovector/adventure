require "classes/game"
require "classes/sheet"

local sheet = Sheet.new("background")
local quad = MOAIGfxQuad2D.new()
quad:setTexture("assets/rooms/outside/art.png")
quad:setRect(0, 0, 1280, 720)
quad:setUVRect(0, 0, 1, 1)

local prop = MOAIProp2D.new()
prop:setDeck(quad)

sheet:insertProp(prop)
sheet:install()

sheet:allowClick(true)
sheet:allowHover(true)


function sheet:onHover()
    game.setHoverText("")
    game.setCursor(0)
    return true
end

function sheet:onClick(prop, x, y, down)
    if down then
        game.addVisualization(function()
            MOAIGfxDevice.setPenColor(0, 0, 1)
            MOAIDraw.fillRect(x - 8, y - 8, x + 8, y + 8)
        end, 3)
    end
        
    return true
end
