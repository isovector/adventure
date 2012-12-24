--- Items are inventory objects Actors may hold.
-- Their skeletons are generated via `make items` from image files in /assets/items.
-- Items are automatically loaded via the 2-load-items.lua service.

mrequire "classes/class"

local items = { }

--- The Item class.
-- Constructor signature is (id, name, tags).
-- The tags are passed to the narrator when appropriate.
-- @newclass Item
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

--- Static method to return an item by id
-- @param id
function Item.getItem(id)
    return items[id]
end

--- Does this item have a certain tag?
-- @param tag
function Item:hasTag(tag)
    return self.tags[tag]
end
