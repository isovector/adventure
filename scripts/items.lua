items = { }

function items.create(id, name, bmpfile)
    local item = {
        id = id,
        name = name,
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