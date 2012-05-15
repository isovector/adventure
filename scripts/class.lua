function newclass(name, ctor)
    _G[name] = { }
    
    local class = _G[name]
    class.__index = class
    
    function class.new(...)
        local instance = { }
        if ctor then
            instance = ctor(...)
        end
        
        instance.__class = class
        setmetatable(instance, class)
        return instance
    end
    
    function class.__tostring()
        return "Object:" .. name
    end
    
    function class:is_a(b)
        return self.__index == b.__index
    end
    
    return class
end
