mrequire "classes/sheet"

local sheet = Sheet.new("background")

sheet:setClickAcceptor(Sheet.all_acceptor)
sheet:setRClickAcceptor(Sheet.all_acceptor)
sheet:setHoverAcceptor(Sheet.all_acceptor)
sheet:install()

--------------------------------------------------

import player from Adventure

--------------------------------------------------

local quad = MOAIGfxQuad2D.new()
quad:setRect(0, 0, 1280, 720)
quad:setUVRect(0, 0, 1, 1)

local prop = MOAIProp2D.new()
prop:setDeck(quad)

sheet:insertProp(prop)

--------------------------------------------------

local function setBackground(path)
    if type(path) == "Costume" then
        error("no support for costume hotspotting yet")
    end
    
    quad:setTexture(path)
end

game:add("setBackground", setBackground)

--------------------------------------------------

function sheet:onHover()
    game.setCurrentObject(nil)
    game.setCursor(0)
    return true
end

function sheet:onClick(prop, x, y, down)
    if not down then return true end
    
    if game.getCurrentItem() then
        game.setCurrentItem(nil)
        return true
    end
    
    if player.prop then
        player:walkToAsync(x, y)
    end
    
    return true
end

function sheet:onRClick(prop, x, y, down)
    if down then
        if game.getCurrentItem() then
            game.setCurrentItem(nil)
        else
            game.showInventory(player)
        end
    end
end
