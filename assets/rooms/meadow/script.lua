import isOpen = false from Adventure.save.meadow
import car, santino from Adventure.actors

function events.__utility.reload()
    car.costume:setPose(isOpen and "open" or "idle")
end

function events.car.look()
    if not isOpen then
        santino:say("It's a beater")
    else
        santino:say("It's a beater and the hood is up")
    end
end

function events.car.hood.touch()
    local x, y = car:location()

    santino:walkTo(x - 75, y + 50)
    
    isOpen = not isOpen
    car.costume:setPose(isOpen and "open" or "idle")
end

function events.car.hood.look()
    santino:say("It's the hood of the car")
end

function events.car.sparkles.look()
    Room.change("hood")
end
