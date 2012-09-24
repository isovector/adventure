require "classes/class"

local function sandboxLookup(t, k)
    local mt = getmetatable(t)

    local self = mt.self
    if self.values[k] then
        return setmetatable({ }, {
            __index = self.values[k],
            __newindex = function(nt, nk, nv)
                if not self.results[k] then
                    self.results[k] = { }
                end
                
                self.results[k][nk] = nv
            end
        })
    end
    
    return mt.globals[k]
end

newclass("Sandbox",
    function()
        local sandbox =  {
            values = { },
            results = { }
        }
        
        sandbox.mt = {
            __index = sandboxLookup,
            self = sandbox,
            globals = _G
        }
        
        return sandbox
    end
)

function Sandbox:addValue(name, value)
    self.values[name] = value
end

function Sandbox:resetResults()
    self.results = { }
end

function Sandbox:getResults()
    return self.results
end

function Sandbox:dofile(path)
    self:call(dofile, path)
end

function Sandbox:call(callback, ...)
    local mt = getmetatable(_G)
    
    setmetatable(_G, self.mt)
    callback(...)
    setmetatable(_G, mt)
end
