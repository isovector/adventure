-- attaches the logger to a table, so any logs written to it will be
-- rerouted to stdout
function debug.attach(tab)
    local mt = getmetatable(tab)
    tab.log = nil
    
    
    if not mt then
        setmetatable(tab, {
            __newindex = function(t, key, val)
                    if key == "log" then
                        debug.log(val)
                    else
                        rawset(t, key, val)
                    end
                end
        })
    else
        if not mt.__newindex then
            mt.__newindex = function(t, key, val)
                    if key == "log" then
                        debug.log(val)
                    else
                        rawset(t, key, val)
                    end
                end
        else
            local oldindex = mt.__newindex
            mt.__newindex = function(t, key, val)
                    if key == "log" then
                        debug.log(val)
                    else
                        oldindex(t, key, val)
                    end
                end
        end
    end
end

-- calls func(name, val) for every local in the calling scope
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

-- internal function to output data for the logger
function debug.log(...)
    local func = debug.getinfo(3)
    print(unpack(arg))

    print("\tfrom " .. func.short_src .. " at " .. func.currentline)

    if func.namewhat ~= "" then
        print("\tdefined in " .. func.namewhat .. " between " .. func.linedefined
            .. ", " .. func.lastlinedefined)
    end
    print()
end