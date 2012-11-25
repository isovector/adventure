require "classes/class"

local indent = 0

--------------------------------------------------

newclass("Serialize",
    function()
        return { }
    end
)

function Serialize.getIndent(indent)
    local ret = ""
    for i = 1, indent do
        ret = "    " .. ret
    end
    
    return ret
end

function Serialize.put(f, obj, ...)
    if not obj.__serialize then
        error("No serialize method for type " .. type(obj))
    end
    
    indent = indent + 1
    obj:__serialize(f, Serialize.getIndent(indent), ...)
    indent = indent - 1
end
