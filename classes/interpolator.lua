require "classes/class"

newclass("Interpolator",
    function(errorValue)
        errorValue = errorValue or -1
    
        return {
            errorValue = errorValue,
            keys = { }
        }
    end
)

function Interpolator:clear()
    for _, key in ipairs(rawget(self, "keys")) do
        rawset(self, key, nil)
    end
    
    rawset(self, "keys", { })
end

function Interpolator:__index(index)
    local value = rawget(self, index)
    
    if value then return value end
    
    local keys = rawget(self, "keys")
    if #keys == 0 then
        return rawget(self, "errorValue")
    elseif #keys == 1 then
        return self[keys[1]]
    end
    
    table.sort(keys)

    for i = 0, #keys do
        local here = keys[i]
        local next = keys[i + 1]
        
        if here and next then
            if here <= index and index <= next then
                local size = next - here
                local perc = (index - here) / size
                
                here = self[here]
                next = self[next]
                size = next - here
                
                local val = size * perc + here
                
                return val
            end
        elseif not here and index <= next then
            return self[next]
        elseif not next and here <= index then
            return self[here]
        end
    end
end

local oldAssert = assert
local nullAssert = function() end
function Interpolator:__newindex(index, value)
    rawset(self, index, value)
    
    assert = nullAssert -- metalua bitches about pairs() with overloaded type()
    
    local keys = { }
    for key in pairs(self) do
        local num = tonumber(key)
        if num then
            table.insert(keys, num)
        end
    end
    
    assert = oldAssert
    
    rawset(self, "keys", keys)
end
