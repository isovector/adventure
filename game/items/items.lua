items = {}
item_events = {}

for filename, attr in dirtree("game/items", ".lua") do
    if filename:sub(-9) ~= "items.lua" then
        dofile(filename);
    end
 end