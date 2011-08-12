current_room = "";
room = nil

function do_callback(callback_type, object, method)
    local name = object .. "_" .. method;
    local func = function() 
        if callback_type == "hotspot" and room[name] then
            room[name]()
        elseif callback_type == "item" and item_events[name] then
            item_events[name]()
        else
            unhandled_event()
        end
    end
    
    if func then 
        tasks.begin(func) 
    end
end

function unhandled_event()
    print("default unhandled_event()")
end

function load_room(r)
    current_room = r
    
    local roompath = "rooms/" .. current_room .. "/"
    __load_room(roompath .. "art.pcx", roompath .. "hot.pcx")
    
    dofile(roompath .. "room.lua")

    room = _G[current_room]
end