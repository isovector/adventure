local charles = charles
local player = santino

local carpet = carpet

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

function charles.talk()
    local x, y = charles:location()
    player:walkTo(x, y + 100)
    topic:show()
end

function charles.look()
    player:say("it's charles")
    player:say("he's a cool cat")
    Task.sleep(1.5)
    player:say("i guess")
end
