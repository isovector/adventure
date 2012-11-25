local player = Actor.getActor("santino")
local charles = Actor.getActor("charles")

local topic = Topic.new("test")
topic:addOptions(
    {
        caption = "Hello Charles",
        flags = "o",
        callback = function()
            charles:say("Hello Santino. How are you doing?")
        end
    },
    {
        caption = "Goodbye",
        flags = "x",
        callback = function()
            charles:say("Peace")
        end
    }
)

function events.charles.masks()
    player:removeItem("masks")

    local x, y = charles:location()
    player:walkTo(x, y + 100)
    player:say("Hey charles! you dig this mask?")
    charles:say("heck yeah! thanks!")
end

function events.charles.talk()
    local x, y = charles:location()
    player:walkTo(x, y + 100)
    topic:show()
end

function events.charles.look()
    player:say("it's charles")
    player:say("he's a cool cat")
    Task.sleep(1.5)
    player:say("i guess")
end
