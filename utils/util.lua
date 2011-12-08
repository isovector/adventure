function nl()
    io.stderr:write("\n")
end

function printe(...)
    io.stderr:write(...)
    nl()
end

function prompt(msg)
    nl()
    printe(msg)
    
    io.stderr:write("> ")
    return io.read()
end

function flag(flags, which)
    return type(flags:find(which)) ~= "nil"
end