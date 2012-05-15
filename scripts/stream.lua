stream = { async = { } }

function stream.operator(lhs, rhs)
    if type(rhs) ~= "table" then
        rhs = { rhs }
    end
    
    if type(lhs) == "table" then
        if lhs.__stream and type(lhs.__stream) == "function" then
            lhs:__stream(rhs)
            return
        elseif lhs.is_a then
            error("left-most stream operation must have a __stream() method")
        end
    end
        
    table.insert(rhs, 1, lhs)
    return rhs
end
