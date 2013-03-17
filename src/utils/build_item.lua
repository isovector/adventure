function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

print(string.format("Item.new(%q, %q, \"\")", arg[1], firstToUpper(arg[1])))
