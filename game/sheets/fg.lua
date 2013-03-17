mrequire "src/game/actor"
mrequire "src/game/costume"
mrequire "src/engine/sheet"

local sheet = Sheet.new("foreground")

sheet:setClickAcceptor(Sheet.prop_acceptor)
sheet:setHoverAcceptor(Sheet.prop_acceptor)
sheet:install()

--------------------------------------------------

local props = { }

local function makeProp(name)
    if props[name] then
        return props[name]
    end
    
    local prop = MOAIProp2D.new()
    sheet:insertProp(prop)
    
    props[name] = prop
    
    return prop
end

local function destroyProp(name)
    sheet:removeProp(props[name])
    props[name] = nil
end

game:add("makeProp", makeProp)
game:add("destroyProp", destroyProp)

--------------------------------------------------

function sheet:onClick(prop, x, y, down)
    if prop then
        game.interactWith(x, y, down)
        return true
    end
    
    return false
end

function sheet:onHover(prop, x, y)
    if prop.actor then
        game.setCurrentObject(prop.actor.hitHotspot or prop.actor)
    else
        game.setCurrentObject(nil)
    end
    
    game.setCursor(5)

    return true
end
