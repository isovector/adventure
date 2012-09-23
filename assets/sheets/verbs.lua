require "classes/game"
require "classes/sheet"

local sheet = Sheet.new("verbs")

sheet:setHoverAcceptor(Sheet.all_acceptor)
sheet:setClickAcceptor(Sheet.all_acceptor)
sheet:enable(false)
sheet:install()

--------------------------------------------------

local quad = MOAIGfxQuad2D.new()
quad:setRect(-72, -24, 72, 24)
quad:setUVRect(0, 0, 1, 1)
quad:setTexture("assets/static/actionbar.png")

local prop = MOAIProp2D.new()
prop:setDeck(quad)
sheet:insertProp(prop)

--------------------------------------------------

local callback = nil
local args = { }
local name = ""

local x0 = 0
local y0 = 0

local timer = nil
local function timerDelta(timer)
    if not game.isMouseDown() then
        timer:stop()
    end
end

local function show(cb, objname, ...)
    sheet:enable(true)
end

local function startVerbCountdown(x, y, cb, objname, ...)
    x0 = x
    y0 = y

    callback = cb
    name = objname
    args = { ... }
    
    prop:setLoc(x0, y0)

    timer = Timer.new(0.75, false, show, timerDelta)
end

game.export("startVerbCountdown", startVerbCountdown)

--------------------------------------------------

local function getVerb(prop, x, y)
    if not prop then return "..." end
    
    if x - x0 < -24 then
        return "Talk"
    elseif x - x0 > 24 then
        return "Touch"
    end
    
    return "Look"
end

--------------------------------------------------

function sheet:onHover(prop, x, y)
    if prop then
        game.setCursor(5)
    else
        game.setCursor(0)
    end
    
    game.setHoverText(string.format("%s %s", getVerb(prop, x, y), name))
    return true
end

function sheet:onClick(prop, x, y, down)
    if down then
        return true
    end
    
    self:enable(false)
    
    if prop then
        callback(getVerb(prop, x, y), unpack(args))
    end
    
    return true
end
