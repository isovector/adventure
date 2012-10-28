function newclass(name, ctor)
    _G[name] = { }
    
    local class = _G[name]
    class.__index = class
    
    function class.new(...)
        local instance = { }
        if ctor then
            instance = ctor(unpack(arg))
        end
        
        instance.__class = class
        setmetatable(instance, class)
        return instance
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
