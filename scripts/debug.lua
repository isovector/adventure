debug.ROOM = 2
debug.DISPATCH = 3
debug.TASKS = 3
debug.ROOM = 3


debug.log_level = 5
debug.log_details = true
debug.last_level = 999

function debug.locals(func)
    if not func then func = print end

    local i = 1
    while true do
        local name, value = debug.getlocal(2, i)
        if name == nil then break end

        func(name, value)
        i = i + 1
    end
end

function debug.logm(level, ...)
    if type(level) ~= "number" then
        arg = {level, unpack(arg)}
        level = debug.last_level
    end

    if level <= debug.log_level then
        print(unpack(arg))
    end

    debug.last_level = level
end

function debug.log(level, ...)
    if type(level) ~= "number" then
        arg = {level, unpack(arg)}
        level = debug.last_level
    end

    if level <= debug.log_level then
        local func = debug.getinfo(2)
        print(unpack(arg))

        if debug.log_details then
            print("from " .. func.short_src .. " at " .. func.currentline)

            if func.namewhat ~= "" then
                print("defined in " .. func.namewhat .. " between " .. func.linedefined
                    .. ", " .. func.lastlinedefined)
            end
            print()
        end
    end

    debug.last_level = level
end