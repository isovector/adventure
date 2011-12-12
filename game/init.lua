engine.add_verb("talk", "Talk to %s", vec(0), vec(48))
engine.add_verb("look", "Look at %s", vec(48, 0), vec(48))
engine.add_verb("touch", "Touch %s", vec(96, 0), vec(48))

load_module("game/dialogue/dialogue.lua")
load_dir("game/actors")
load_dir("game/items")
load_dir("game/rooms", function(filename)
    rooms[filename].events.init()
end)