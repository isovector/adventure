load_script("scripts/library.lua")
load_script("scripts/geometry.lua")
load_script("scripts/rig.lua")
load_script("scripts/tasks.lua")
load_script("scripts/drawing.lua")
load_script("scripts/filesystem.lua")

load_script("scripts/repl.lua")

load_script("scripts/engine.lua")

drawing.clear(color.make(255, 255, 0))

events.game.tick.sub()