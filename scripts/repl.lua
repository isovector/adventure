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
   
      
    for key, val in pairs(tab) do
        console_line(indent, tostring(key) .. "  =  " .. tostring(val))
    end
    
    console_line("", "}")
end