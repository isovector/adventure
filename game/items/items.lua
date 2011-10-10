items = {}
item_events = {}

for filename, attr in fs.directories("game/items") do
    dofile("game/items/" .. filename .. "/" .. filename .. ".lua");
end