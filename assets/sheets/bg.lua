require "classes/game"
require "classes/sheet"

local sheet = Sheet.new("background")

sheet:setClickAcceptor(Sheet.all_acceptor)
sheet:setRClickAcceptor(Sheet.all_acceptor)
sheet:setHoverAcceptor(Sheet.all_acceptor)
sheet:install()

--------------------------------------------------

local quad = MOAIGfxQuad2D.new()
quad:setRect(0, 0, 1280, 720)
quad:setUVRect(0, 0, 1, 1)

local prop = MOAIProp2D.new()
prop:setDeck(quad)

sheet:insertProp(prop)

--------------------------------------------------

local function setBackground(path)
    quad:setTexture(path)
end

game.export("setBackground", setBackground)

--------------------------------------------------

function sheet:onHover()
    game.setHoverText("")
    game.setCursor(0)
    return true
end

function sheet:onClick(prop, x, y, down)
    if not down then return true end
    
    local actor = Actor.getActor("santino")
    if room.scene[actor.id] then
        actor:setGoal(x, y)
    end
    
    return true
end

function sheet:onRClick(prop, x, y, down)
    if down then
        game.showInventory(Actor.getActor("santino"))
    end
end
