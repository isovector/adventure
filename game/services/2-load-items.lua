mrequire "src/game/item"

for _, item in ipairs(MOAIFileSystem.listFiles("game/items")) do
    if item:sub(-4) == ".lua" then
        require("game/items/" .. item:sub(1, -5))
    end
end
