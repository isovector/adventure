mrequire "src/game/actor"
mrequire "src/game/item"
mrequire "src/engine/sheet"

local sheet = Sheet.new("inventory")

sheet:setClickAcceptor(Sheet.all_acceptor)
sheet:setRClickAcceptor(Sheet.all_acceptor)
sheet:setHoverAcceptor(Sheet.all_acceptor)
sheet:install()
sheet:enable(false)

--------------------------------------------------

local xnum = 9
local ynum = 3
local width = 740
local height = 300

--------------------------------------------------

local quad = MOAIGfxQuad2D.new()
quad:setRect(-width / 2, -height / 2, width / 2, height / 2)
quad:setUVRect(0, 0, 1, 1)
quad:setTexture("game/static/inventory.png")

local framequad = MOAIGfxQuad2D.new()
framequad:setRect(-36, -36, 36, 36)
framequad:setUVRect(0, 0, 1, 1)
framequad:setTexture("game/static/frame.png")

local prop = MOAIProp2D.new()
prop:setDeck(quad)
prop:setLoc(1280 / 2, 720 / 2)
sheet:insertProp(prop)

--------------------------------------------------

local items = { }

local function makeProp(item, x, y)
    local quad = MOAIGfxQuad2D.new()
    quad:setRect(-32, -32, 32, 32)
    quad:setUVRect(0, 0, 1, 1)
    quad:setTexture(item.img)

    local prop = MOAIProp2D.new()
    prop:setDeck(quad)
    prop:setLoc(x, y)
    prop:setPriority(105)
    sheet:insertProp(prop)
    
    prop.item = item
    
    return prop
end

local function showInventory(actor)
    if sheet.enabled and not actor then
        for _, prop in ipairs(items) do
            sheet:removeProp(prop)
        end
        
        items = { }
    
        sheet:enable(false)
        return
    end
    
    local i = 0
    for id, item in pairs(actor.inventory) do
        local x = 1280 / 2 - 352 + 80 * (i % xnum) + 32
        local y = 720 / 2 - 132 + 76 * math.floor(i / xnum) + 32
        
        local frame = MOAIProp2D.new()
        frame:setDeck(framequad)
        frame:setLoc(x, y)
        frame:setPriority(100)
        sheet:insertProp(frame)
        
        table.insert(items, frame)
        table.insert(items, makeProp(item, x, y))
        
        i = i + 1
    end

    sheet:enable(true)
end

game:add("showInventory", showInventory)

--------------------------------------------------

function sheet:onClick(prop, x, y, down)
    if prop and prop.item then
        game.interactWith(x, y, down, function() game.setCurrentItem(prop.item) end)
    end
    
    if not prop then
        showInventory(nil)
    end
    
    return true
end

function sheet:onHover(prop, x, y)
    if prop and prop.item then
        game.setCurrentObject(prop.item)
        game.setCursor(5)
    else
        game.setCurrentObject(nil)
        game.setCursor(0)
    end
    
    return true
end

function sheet:onRClick(prop, x, y, down)
    if down then
        showInventory(nil)
    end
    
    return true
end
