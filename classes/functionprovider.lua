mrequire "classes/class"

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


function FunctionProvider.__newindex()
    error("Functions may only be added to the Functionprovider via add()")
end

function FunctionProvider:__index(key)
    if self.funcs[key] then
        local result = dispatchFunctions
        debug.setupvalue(result, 1, self.funcs[key])
        return result
    end

    return rawget(self.__class, key) or error(key .. " hasn't been added to the FunctionProvider. Check your spelling and requires")
end


local function addTable(self, t)
    for name, func in pairs(t) do
        self:add(name, func)
    end
end

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
