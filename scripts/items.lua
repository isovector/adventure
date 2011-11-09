items = { }

function items.create(id, name, bmpfile)
    local item = {
        id = id,
        label = name,
        image = bitmap(bmpfile),

        events = {
            touch = event.create(),
            talk = event.create(),
            look = event.create(),
            item = event.create()
        }
    }
    
    items[id] = item
    return item
end