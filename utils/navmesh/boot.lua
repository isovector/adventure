load_script("scripts/rig.lua")
load_script("scripts/tasks.lua")
load_script("scripts/drawing.lua")
load_script("scripts/filesystem.lua")
load_script("scripts/repl.lua")

vertices = { }
triangles = { }
rects = { }
engine.mouse.cursor = 10

image = bitmap("game/rooms/outside/art.pcx")

dofile("utils/navmesh/logic.lua")
dofile("utils/navmesh/drawing.lua")
