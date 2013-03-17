import 
    playedIntro = false,
    isOpen = false 
    from Adventure.save.meadow
    
import room from Adventure
import car, santino, taag from Adventure.actors

mrequire "src/engine/sheet"
mrequire "src/engine/task"

function events.__utility.reload()
    car.costume:setPose(isOpen and "open" or "idle")
    
    if not playedIntro then
        playedIntro = true
        Task.start(function()
            Sheet.enableInput(false)
            Task.sleep(1)
            taag:say("Well I guess it's all wrapped up then.")
            taag:say("Enjoy your brand \"new\" car!")
            santino:say("So uh, this comes with the standard warranty...")
            santino:say("Right?")
            taag:say("HA HA HA HA")
            taag:say("Er... well.. about that...")
            taag:say("Let me go.. uh... check on that.")
            taag:exitRoomByDoor("ledge")
            Sheet.enableInput(true)
        end)
    end
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
