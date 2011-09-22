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