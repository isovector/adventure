require "classes/class"

local items = { }

newclass("Item",
    function(id, name, tags)
        local ttags = { }
        
        for token in string.gmatch(tags, "[^,]+") do
            table.insert(ttags, token)
        end
        
        local img = MOAIImageTexture.new()
        img:load("assets/items/" .. id .. ".png", MOAIImage.TRUECOLOR + MOAIImage.PREMULTIPLY_ALPHA)
        
        local item = {
            id = id,
            img = img,
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
