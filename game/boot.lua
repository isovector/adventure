load_script("scripts/library.lua")
load_script("scripts/geometry.lua")
load_script("scripts/rig.lua")
load_script("scripts/tasks.lua")
load_script("scripts/drawing.lua")
load_script("scripts/filesystem.lua")

load_script("scripts/dialogue.lua")
load_script("scripts/repl.lua")

load_script("scripts/engine.lua")
load_script("game/logic.lua")
load_script("game/drawing.lua")
load_script("scripts/animation.lua")

load_script("scripts/actors.lua")
load_script("scripts/rooms.lua")
load_script("scripts/items.lua")

load_script("scripts/path.lua")
load_script("scripts/clock.lua")
load_script("scripts/game.lua")

-- initialize verbs

engine.add_verb("talk", "Talk to %s", vec(0), vec(48))
engine.add_verb("look", "Look at %s", vec(48, 0), vec(48))
engine.add_verb("touch", "Touch %s", vec(96, 0), vec(48))

-- load content

load_script("game/dialogue/dialogue.lua")
load_dir("actors")
load_dir("items")
load_dir("rooms", function(filename)
    rooms[filename].events.init()
end)

-- setup game

rooms["outside"].switch()
enable_path(17)
player = actors.gomez

player.events.tick.sub(function(elapsed)
    local xoffset = math.clamp(player.pos.x - screen_width / 2, 0, room_width - screen_width)
    local yoffset = math.clamp(player.pos.y - screen_height / 2, 0, room_height - screen_height)
    
    --set_viewport(xoffset, yoffset)
end)

clock.set_speed(25, 60)