actors = {}

-- automatically load all actors
for filename, attr in dirtree("game/actors", ".lua") do
    if filename:sub(-13) ~= "animation.lua" and filename:sub(-10) ~= "actors.lua" then
        dofile(filename);
    end
 end