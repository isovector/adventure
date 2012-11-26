local car = Actor.getActor("car")
local player = Actor.getActor("santino")

local isopen = false

function events.car.look()
    if not isopen then
        player:say("It's a beater")
    else
        player:say("It's a beater and the hood is up")
    end
end

function events.car.hood.touch()
    local x, y = car:location()

    player:walkTo(x - 75, y + 50)
    
    isopen = not isopen
    car.costume:setPose(isopen and "open" or "idle")
end

function events.car.hood.look()
    player:say("It's the hood of the car")
end

function events.car.sparkles.look()
    player:say("There appear to be sparkles where the engine should be")
end
