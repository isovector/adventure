require "classes/class"

local items = { }

newclass("Item",
    function(id, name, tags)
        local ttags = { }
        
        for token in string.gmatch(tags, "[^,]+") do
            ttags[token] = token
        end
        
        local item = {
            id = id,
            name = name,
            tags = ttags
        }
        
        items[id] = item
        
        return item
    end
)

function Item.getItem(id)
    return items[id]
end

function Item:hasTag(tag)
    return self.tags[tag]
end
