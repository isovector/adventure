items = { }

function items.create(id, name, bitmap)
    local item = {
        id = id,
        label = name,
        image = get_bitmap(bitmap),

        events = {
            touch = event.create(),
            talk = event.create(),
            look = event.create()
        }
    }
    
    items[id] = item
    return item
end