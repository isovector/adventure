current_room = "";
room = nil
rooms = {}

function do_callback(callback_type, object, method)
    local name = object .. "_" .. method
    local obj = table.find(room.scene, function(key, val)
            return val.id == object
        end)

    debug.logm(debug.DISPATCH, "dispatching", callback_type, name)
    debug.log("on", obj and obj.id)

    tasks.begin({
        function()
            if room.events and room.events[name] then
                return room.events[name]()
            end
            return true
        end,
        function()
            if item_events and item_events[name] then
                return item_events[name]()
            end
            return true
        end,
        function()
            if obj and obj.events and obj.events[name] then
                return obj.events[name]()
            end
            return true
        end,
        function()
            if events and events[name] then
                return events[name]()
            end
            return true
        end,
        function()
            if unhandled_event then
                unhandled_event(callback_type, object, method)
            end
        end,
    }, true)
end

function unhandled_event(callback_type, object, method)
    debug.log(debug.DISPATCH, "failed to dispatch event", object .. "_" .. method)
end

function switch_room(r, door)
    debug.logm(debug.ROOM, "switching to room", r)
    debug.log("via door", door)

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