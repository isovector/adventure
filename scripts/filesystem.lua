require "lfs"

fs = {}

function fs.directories(dir)
    assert(dir and dir ~= "", "directory parameter is missing or empty")
    if string.sub(dir, -1) == "/" then
        dir=string.sub(dir, 1, -2)
    end
    
    local function yieldtree(dir)
        for entry in lfs.dir(dir) do
            if entry ~= "." and entry ~= ".." then
                local attr = lfs.attributes(dir .. "/" .. entry)
                if attr.mode == "directory" then
                    coroutine.yield(entry, attr)
                end
            end
        end
    end

  return coroutine.wrap(function() yieldtree(dir) end)
end

function fs.dirtree(dir, filter)
    if not filter then filter = "" end

    assert(dir and dir ~= "", "directory parameter is missing or empty")
    if string.sub(dir, -1) == "/" then
        dir=string.sub(dir, 1, -2)
    end

    local function yieldtree(dir)
        for entry in lfs.dir(dir) do
            if entry ~= "." and entry ~= ".." then
                entry = dir .. "/" .. entry
                
                local attr = lfs.attributes(entry)
                if attr.mdoe ~= "directory" and entry:sub(-#filter) == filter then
                    coroutine.yield(entry, attr)
                end
                
                if attr.mode == "directory" then
                    yieldtree(entry)
                end
            end
        end
    end

  return coroutine.wrap(function() yieldtree(dir) end)
end