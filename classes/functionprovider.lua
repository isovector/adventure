--- Acts as both a global function store and as a
-- way of collescing multiple functions into one.

mrequire "classes/class"

--- The FunctionProvider class.
-- Constructor signature is ().
-- @newclass FunctionProvider
newclass("FunctionProvider",
    function()
        return {
            funcs = { }
        }
    end
)

local temp = { }
local function dispatchFunctions(...)
    local ret
    for _, f in ipairs(temp) do
        local v = { f(...) }
        
        if #v ~= 0 then 
            ret = ret or v
        end
    end
    
    if ret then
        return unpack(ret)
    end
end

--- Informs the user that you may not directly newindex a FunctionProvider.
function FunctionProvider.__newindex()
    error("Functions may only be added to the FunctionProvider via add()")
end

--- Returns the multifunction associated with the given key.
-- @param key
-- @return A function which when called will evaluate all of the functions given by the key.
function FunctionProvider:__index(key)
    if self.funcs[key] then
        local result = dispatchFunctions
        debug.setupvalue(result, 1, self.funcs[key])
        return result
    end

    return rawget(self.__class, key) or error(key .. " hasn't been added to the FunctionProvider. Check your spelling and requires")
end

--- Internal function to add multiple functions to a FunctionProvider at once.
-- @param self The FunctionProvider instance
-- @param t The table of key => value pairs to add
local function addTable(self, t)
    for name, func in pairs(t) do
        self:add(name, func)
    end
end

--- Adds a function to the FunctionProvider
-- @param name
-- @param func
function FunctionProvider:add(name, func)
    if not func and type(name) == "table" then
        addTable(self, name)
        return
    end
    
    if not self.funcs[name] then
        self.funcs[name] = { }
    end
    
    table.insert(self.funcs[name], func)
end
