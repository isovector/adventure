function newclass(name, ctor)
    _G[name] = { }
    
    local class = _G[name]
    class.__index = class

    -- if ctor is false, this is a static class
    if ctor ~= false then
        function class.new(...)
            local instance = { }
            if ctor then
                instance = ctor(...)
            end
            
            if not instance then
                error(string.format("class `%s's constructor did not return an object", name))
            end
            
            instance.__class = class
            setmetatable(instance, class)
            return instance
        end
    end
    
    function class:__tostring()
        if self.id then
            return string.format("[%s::%s]", name, self.id)
        else
            return string.format("[%s]", name)
        end
    end
    
    function class:is_a(b)
        return self.__index == b.__index
    end
    
    class.__type = name
    
    return class
end

--------------------------------------------------

local origType = type
function type(object)
    local t = origType(object)
    
    if t == "table" then
        return object.__type or t
    end
    
    return t
end
