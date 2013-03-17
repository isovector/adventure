--- The serializer class. This manages recursive serializations.

require "src/class"

local indent = 0

--------------------------------------------------


--- The Serialize class.
-- @newclass Serialize
newclass("Serialize",
    function()
        return { }
    end
)

--- Returns a string representing the indenting for a given block depth.
-- @param indent
function Serialize.getIndent(indent)
    local ret = ""
    for i = 1, indent do
        ret = "    " .. ret
    end
    
    return ret
end

--- Recursively serializes an object into f.
-- @param f
-- @param obj
function Serialize.put(f, obj, ...)
    if not obj.__serialize then
        error("No serialize method for type " .. type(obj))
    end
    
    indent = indent + 1
    obj:__serialize(f, Serialize.getIndent(indent), ...)
    indent = indent - 1
end
