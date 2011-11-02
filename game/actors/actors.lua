-- automatically load all actors
for filename, attr in fs.directories("game/actors") do
    dofile("game/actors/" .. filename .. "/" .. filename .. ".lua");
end