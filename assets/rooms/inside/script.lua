local charles = charles
local player = santino

local carpet = carpet

function charles.talk()
    local x, y = charles:location()
    player:walkTo(x, y + 100)
    player:say("hello charles")
    charles:say("hello player")
end

function charles.look()
    player:say("it's charles")
    player:say("he's a cool cat")
    sleep(1.5)
    player:say("i guess")
end

function carpet.press()
    local x, y = player:location()
    player:setGoal(x + 50, y)
end
