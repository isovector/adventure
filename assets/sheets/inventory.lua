require "classes/actor"
require "classes/item"
require "classes/game"
require "classes/sheet"

local sheet = Sheet.new("inventory")

sheet:setClickAcceptor(Sheet.all_acceptor)
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
quad:setTexture("assets/static/inventory.png")

local framequad = MOAIGfxQuad2D.new()
framequad:setRect(-36, -36, 36, 36)
framequad:setUVRect(0, 0, 1, 1)
framequad:setTexture("assets/static/frame.png")

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
end

local function showInventory(actor)
    if sheet.enabled then
        for _, prop in ipairs(items) do
            sheet:removeProp(prop)
        end
    
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
        
        makeProp(item, x, y)
        
        i = i + 1
    end
    
    sheet:enable(true)
end

game.export("showInventory", showInventory)

--------------------------------------------------

function sheet:onClick(prop, x, y, down)
    if down and prop and prop.item then
        game.startVerbCountdown(x, y, prop.item)
    end
    
    return true
end

function sheet:onHover(prop, x, y)
    if prop and prop.item then
        game.setCursor(5)
        game.setHoverText(prop.item.name)
    else
        game.setCursor(0)
        game.setHoverText("")
    end
    
    return true
end
