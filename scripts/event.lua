event = { }
events = { }

function event.create()
    local ev = { subscribers = { } }
    
    function ev.sub(sub)
        table.insert(ev.subscribers, sub)
    end
    
    function ev.unsub(sub)
        local pos = table.contains(ev.subscribers, sub)
            
        if pos then
            table.remove(ev.subscribers, pos)
        end
    end
    
    setmetatable(ev, {
        __call = function(event, ...)
            local count = 0
        
            for key, subscriber in ipairs(event.subscribers) do
                subscriber(...)
                count = count + 1
            end
            
            return count
        end
    })
    
    return ev
end