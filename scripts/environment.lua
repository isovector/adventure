readonly = {
    locks = { },
    indexer = function(tab, name, value)
        if readonly.locks[name] ~= nil then
            error(name ..' is a read only variable', 2)
        end
        rawset(tab, name, value)
    end
}

setmetatable(_G, { __index = readonly.locks, __newindex = readonly.indexer })

load = { }
function load.script(file)
    file = "obj/" .. file .. "c"
    --print(file)
    return dofile(file)
end

function load.module(file)
    return load.script(module .. "/" .. file)
end

function load.dir(dir, func)
    for filename, attr in fs.directories(module .. "/" ..dir) do
        load.module(dir .. "/" .. filename .. "/" .. filename .. ".lua");
        
        if func then
            func(filename)
        end
    end
end

load.image = drawing.load
vector = geometry.Vector

sleep = tasks.sleep

load.script("scripts/class.lua")
load.script("scripts/event.lua")
load.script("scripts/debug.lua")
load.script("scripts/stream.lua")
load.script("scripts/serialize.lua")

load.script("scripts/library.lua")
load.script("scripts/filesystem.lua")
load.script("scripts/geometry.lua")

load.script("scripts/input.lua")
load.script("scripts/tasks.lua")
load.script("scripts/engine.lua")

load.script("scripts/drawing.lua")
