mrequire "classes/item"

for _, item in ipairs(MOAIFileSystem.listFiles("assets/items")) do
    if item:sub(-4) == ".lua" then
        require("assets/items/" .. item:sub(1, -5))
    end
end
