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

function load_script(file)
    --print(file)
    return dofile(file)
end

function load_module(file)
    return load_script(module .. "/" .. file)
end

function load_dir(dir, func)
    for filename, attr in fs.directories(module .. "/" ..dir) do
        load_module(dir .. "/" .. filename .. "/" .. filename .. ".lua");
        
        if func then
            func(filename)
        end
    end
end

load_script("scripts/event.lua")
load_script("scripts/debug.lua")
load_script("scripts/serialize.lua")

load_script("scripts/library.lua")
load_script("scripts/geometry.lua")

load_script("scripts/engine.lua")