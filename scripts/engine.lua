current_room = "";
room = nil
rooms = {}

-- make this perform dispatch on object
function do_callback(callback_type, object, method)
    local name = object .. "_" .. method;
    print(name)
    local func = function() 
        if callback_type == "hotspot" and room[name] then
            room[name]()
        elseif callback_type == "item" and item_events[name] then
            item_events[name]()
        elseif callback_type == "object" and _G[name] then
            _G[name]()
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

function switch_room(r, door)
    if current_room == r then return end
    current_room = r
    
    if not rooms[r] then
        local roompath = "rooms/" .. r .. "/"
    
        dofile(roompath .. "room.lua")
        room.artwork = get_bitmap(roompath .. "art.pcx")
        room.hotmap = get_bitmap(roompath .. "hot.pcx")
        
        room.on_init()
        rooms[r] = room
    end
    
    room = rooms[r]
    set_room_data(room.artwork, room.hotmap)
    
    room.on_load(door)
end