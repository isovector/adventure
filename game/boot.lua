load.script("scripts/repl.lua")
load.script("game/logic.lua")
load.script("game/render.lua")
load.script("scripts/game.lua")

-- subscribe to game events

events.game.tick.sub(engine.update)
game.register_actor_updates()
game.register_conversation()

-- initialize verbs

game.add_verb("talk", "Talk to %s", vec(0), vec(48))
game.add_verb("look", "Look at %s", vec(48, 0), vec(48))
game.add_verb("touch", "Touch %s", vec(96, 0), vec(48))

-- load content

load.dir("actors")
load.dir("items")
load.dir("rooms", function(filename)
    rooms[filename].events.init()
end)

-- setup game

rooms["outside"].switch()
enable_path(17)
player = actors.gomez

--[[player.events.tick.sub(function(elapsed)
    local xoffset = math.clamp(player.pos.x - screen_width / 2, 0, room_width - screen_width)
    local yoffset = math.clamp(player.pos.y - screen_height / 2, 0, room_height - screen_height)
    
    --set_viewport(xoffset, yoffset)
end)]]