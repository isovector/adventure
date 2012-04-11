dofile("util.lua")

old_print = print
print = printe

print("- ---------------------------- -")
print("- adventure dialogue generator -")
print("- ---------------------------- -")
print()

local namespace = prompt("What is the namespace for this dialogue?")

local option = ""
local count = 1

local output = namespace .. " = {\n"

while option ~= "-" do
    print("----------------------")
    print()
    print("Dialogue option #" .. count .. ":")
    
    option = prompt("What is the prompt for this option?\t(enter - to continue)")
    
    if option ~= "-" then
        print()
        print()
        
        print("Possible flags:")
        print("s = silent       o = open new topic")
        print("e = exit         1 = just once")
        local flags = prompt("Which flags are applicable?\t(default: none)")
        
        local states = prompt("Which states are required for this option?\t(comma separated)")
        local enable = prompt("Which states should be enabled afterwards?\t(comma separated)")
        
        local instead = ""
        if flag(flags, "s") then
            instead = prompt("What should be said instead?")
        end
        
        local new_topic = ""
        if flag(flags, "o") then
            new_topic = prompt("Which topic should be opened afterwards?")
        end
        
        output = output .. "    {\n"
        output = output .. "        label = \"" .. option .."\",\n"
        
        if flag(flags, "s") then
            output = output .. "        silent = true,\n"
        end
        
        if flag(flags, "1") then
            output = output .. "        once = true,\n"
        end
        
        if states ~= "" then
            output = output .. "        cond = statecond." .. states .. ",\n"
        end
        
        output = output .. "        action = function()\n"
        
        if enable ~= "" then
            output = output .. "            state." .. enable .. " = true\n"
        end
        
        if instead ~= "" then
            output = output .. "            player:say(\"" .. instead .. "\")\n"
        end
        
        output = output .. "            -- insert logic here\n"
        
        if new_topic ~= "" then
            output = output .. "            open_topic(" .. new_topic .. ")\n"
        end
        
        if flag(flags, "e") then
            output = output .. "            end_conversation()\n"
        end
        
        output = output .. "        end\n"
        output = output .. "    },\n"
        
        count = count + 1
    end
end

output = output .. "    _load = function()\n"
output = output .. "        -- insert logic here\n"
output = output .. "    end\n"
output = output .. "}"



old_print(output)