load_script("scripts/rig.lua")
load_script("scripts/tasks.lua")
load_script("scripts/drawing.lua")
load_script("scripts/filesystem.lua")
load_script("scripts/repl.lua")

navigation = { }
hotspots = { }
curhotspot = 0

colors = {  0xFF0000,
            0xFF8800,
            0xFFFF00,
            0x88FF00,
            0x00FF88,
            0x00FFFF,
            0x0088FF,
            0x0000FF,
            0x8800FF,
            0xFF00FF 
        }

vertices = navigation
engine.mouse.cursor = 10

image = bitmap("game/rooms/outside/art.pcx")
hot = create_bitmap(screen_width, screen_height, 0)

dofile("utils/navmesh/logic.lua")
dofile("utils/navmesh/drawing.lua")
