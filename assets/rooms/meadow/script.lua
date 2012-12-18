local car = /Actors/car
local player = /Actors/santino

local meadow = save.meadow

function events.car.look()
    if not save.meadow.isOpen then
        player:say("It's a beater")
    else
        player:say("It's a beater and the hood is up")
    end
end

function events.car.hood.touch()
    local x, y = car:location()

    player:walkTo(x - 75, y + 50)
    
    meadow.isOpen = not *meadow.isOpen
    car.costume:setPose(*meadow.isOpen and "open" or "idle")
end

function events.car.hood.look()
    player:say("It's the hood of the car")
end

function events.car.sparkles.look()
    Room.change("hood")
end
