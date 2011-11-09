function load_module(file)
    dofile(file)
end

function load_dir(dir, func)
    for filename, attr in fs.directories(dir) do
        load_module(dir  .. "/" .. filename .. "/" .. filename .. ".lua");
        
        if func then
            func(filename)
        end
    end
end

-- load the engine
load_module("scripts/environment.lua")
load_module("scripts/library.lua")
load_module("scripts/debug.lua")
load_module("scripts/repl.lua")
load_module("scripts/event.lua")
load_module("scripts/engine.lua")
load_module("scripts/clock.lua")
load_module("scripts/tasks.lua")
load_module("scripts/animation.lua")
load_module("scripts/actors.lua")
load_module("scripts/rooms.lua")
load_module("scripts/items.lua")
load_module("scripts/dialogue.lua")
load_module("scripts/filesystem.lua")
load_module("scripts/drawing.lua")
load_module("scripts/game.lua")

-- load the game
load_module("game/dialogue/dialogue.lua")
load_dir("game/actors")
load_dir("game/items")
load_dir("game/rooms", function(filename)
    rooms[filename].events.init()
end)