local car = Actor.getActor("car")
local player = Actor.getActor("santino")

function events.car.look()
    player:say("It's a beater")
end

function events.car.hood.look()
    player:say("It's the hood of the car")
end
