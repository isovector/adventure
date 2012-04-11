items = { }

newclass("Item", 
    function(id, name, bmp)
        local item = {
            id = id,
            name = name,
            image = bmp,

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
)
