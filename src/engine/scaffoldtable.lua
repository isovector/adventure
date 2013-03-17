--- Provides an automatically expanding table hierarchy.
-- This is used to rapidly declare hierarchical data that won't change during runtime.

mrequire "src/class"

--- The ScaffoldTable class.
-- Constructor signature is (callback, getCallback, lastSeparate, ...).
-- Indexing this table results in automatic copies of itself with a parent pointer.
-- @param callback The function to call when assigning a value to a ScaffoldTable
-- @param getCallback Legacy. To be removed.
-- @param lastSeparate When assigning the table, should the right-most index be passed as a separate parameter to callback?
-- @param ...
-- @newclass ScaffoldTable
newclass("ScaffoldTable",
    function(callback, getCallback, lastSeparate, ...)
        lastSeparate = lastSeparate or false
    
        return { 
            __callback = callback,
            __getCallback = getCallback,
            __lastSeparate = lastSeparate,
            __extra = { ... }
        }
    end
)

--- Returns a table of the position of the current node in a ScaffoldTable.
-- @return The position of the current node in the ScaffoldTable.
function ScaffoldTable:getBreadcrumbs()
    local parent = rawget(self, "__parent")
    if parent then
        local crumbs, root = parent:getBreadcrumbs()
        table.insert(crumbs, rawget(self, "__key"))
        return crumbs, root
    end
    
    return { }, self
end

--- The magic indexing behavior of the ScaffoldTable.
-- If the requested index doesn't exist, this will return a new table parented
-- to the indexee.
-- @param key The name of the new table
function ScaffoldTable:__index(key)
    return rawget(ScaffoldTable, key) 
        or setmetatable({ __parent = self, __key = key }, ScaffoldTable)
end

--- Calls the registered callback when newindexed.
-- @param key
-- @param value
function ScaffoldTable:__newindex(key, value)
    local crumbs, root = self:getBreadcrumbs()
    local callback = rawget(root, "__callback")
    local extra = rawget(root, "__extra")
    
    if rawget(root, "__lastSeparate") then
        callback(crumbs, key, value, unpack(extra))
    else
        table.insert(crumbs, key)
        callback(crumbs, value, unpack(extra))
    end
end

--- Legacy code. To be removed.
function ScaffoldTable:__assign(value)
    local crumbs, root = self:getBreadcrumbs()
    local callback = rawget(root, "__callback")
    local extra = rawget(root, "__extra")
    
    callback(crumbs, value, unpack(extra))
end

--- Legacy code. To be removed.
function ScaffoldTable:__deref()
    local crumbs, root = self:getBreadcrumbs()
    local callback = rawget(root, "__getCallback")
    local extra = rawget(root, "__extra")
    
    if callback then
        return callback(crumbs, value, unpack(extra))
    else
        error("No dereference callback was assigned to the ScaffoldTable")
    end
end
