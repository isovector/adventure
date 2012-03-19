items = { }

function items.create(id, name, bmpfile)
    local item = {
        id = id,
        name = name,
        image = bitmap(bmpfile),

        events = {
            item = event.create()
        }
    }
    
    -- create events for all the verbs
    for id, verb in pairs(game.verbs) do
        item.events[id] = event.create()
    end
    
    items[id] = item
    return item
end