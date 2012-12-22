import(isOpen) from save.meadow

local car = Actors.car
local player = Actors.santino

function events.__utility.reload()
    car.costume:setPose(isOpen and "open" or "idle")
end

function events.car.look()
    if not isOpen then
        player:say("It's a beater")
    else
        player:say("It's a beater and the hood is up")
    end
end

function events.car.hood.touch()
    local x, y = car:location()

    player:walkTo(x - 75, y + 50)
    
    isOpen = not isOpen
    car.costume:setPose(isOpen and "open" or "idle")
end

function events.car.hood.look()
    player:say("It's the hood of the car")
end

function events.car.sparkles.look()
    Room.change("hood")
end
