mrequire "classes/sheet"
mrequire "classes/task"

local sheet = Sheet.new("verbs")

sheet:setHoverAcceptor(Sheet.all_acceptor)
sheet:setClickAcceptor(Sheet.all_acceptor)
sheet:enable(false)
sheet:install()

--------------------------------------------------

import room from Adventure

--------------------------------------------------

local quad = MOAIGfxQuad2D.new()
quad:setRect(-72, -24, 72, 24)
quad:setUVRect(0, 0, 1, 1)
quad:setTexture("assets/static/actionbar.png")

local prop = MOAIProp2D.new()
prop:setDeck(quad)
sheet:insertProp(prop)

--------------------------------------------------

local function getEventCallback(obj, verb)
    local id = obj.id
    
    while obj.proxy do
        obj = obj.proxy
        id = string.format("%s_%s", obj.id, id)
    end

    if id and room.events[id] then
        return room.events[id][verb]
    end
end

game:add("getEventCallback", getEventCallback)

--------------------------------------------------

local object = nil

local x0 = 0
local y0 = 0

local timer = nil
local function timerDelta(timer)
    if not game.isMouseDown() then
        timer:stop()
    end
end

local function show()
    sheet:enable(true)
end

local function dispatchVerb(verb)
    game.setCurrentVerb(nil)
    
    local event = game.getEventCallback(object, verb)
    if event then
        Task.start(function(...)
            game.enableInput(false)
            event(...)
            game.enableInput(true)
        end)
    end
end

local function startVerbCountdown(x, y)
    x0 = x
    y0 = y
    
    prop:setLoc(x0, y0)
    
    object = game.getCurrentObject()

    timer = Timer.new(0.5, false, show, timerDelta)
end

local function interactWith(x, y, down, otherwise)
    local item = game.getCurrentItem()

    object = game.getCurrentObject()
    
    if not down and item then
        dispatchVerb(item.id)
        game.setCurrentItem(nil)
    else
        if down then
            startVerbCountdown(x, y)
        elseif otherwise then
            otherwise(object)
        end
    end
end

game:add("interactWith", interactWith)

--------------------------------------------------

local function getVerb(prop, x, y)
    if not prop then return nil end
    
    if x - x0 < -24 then
        return "talk"
    elseif x - x0 > 24 then
        return "touch"
    end
    
    return "look"
end

--------------------------------------------------

function sheet:onHover(prop, x, y)
    if prop then
        game.setCursor(5)
    else
        game.setCursor(0)
    end
    
    game.setCurrentVerb(getVerb(prop, x, y))
    
    return true
end

function sheet:onClick(prop, x, y, down)
    if down then
        return true
    end
    
    self:enable(false)
    
    if prop then
        dispatchVerb(getVerb(prop, x, y))
    end
    
    return true
end
