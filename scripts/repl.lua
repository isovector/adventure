repl = { active_code = "" }

function repl.line(code)
    code = repl.active_code .. " " .. code
    repl.active_code = ""
    
    local func, err = loadstring(code)
    if not func then
        func = loadstring("return " .. code)
        
        if not func then
            if err:find("'end' expected") then
                repl.active_code = code
                return true
            end

            console_line("!! ", err)
            return false
        else
            repl.result(func(), true)
            return false
        end
    else
        repl.result(func())
        return false
    end
end

function repl.result(result, explicit)
    if result ~= nil or explicit then
        if type(result) == "table" then
            repl.dump(result)
        else
            console_line("", tostring(result))
        end
    end
end

function repl.dump(tab)
    local indent = "  "
    
    console_line("", "{")
    
    local keys = { }
    local len = 0
   
    for key, _ in pairs(tab) do
        table.insert(keys, key)
        
        if #key > len then
            len = #key
        end
    end
    
    table.sort(keys)
   
    for _, key in ipairs(keys) do
        local val = tab[key]
        local prefix = ""
        
        for i = 0, len - #key do
            prefix = prefix .. " "
        end
    
        local output = tostring(val)
        if type(val) == "table" and getmetatable(val) == geometry.vector_mt then
            output = string.format("[%s, %s]", val.x, val.y)
        end
        
        console_line(indent, string.format("%s%s = %s", prefix, tostring(key), output))
    end
    
    console_line("", "}")
end