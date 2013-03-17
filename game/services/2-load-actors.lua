mrequire "src/game/actor"

for _, actor in ipairs(MOAIFileSystem.listFiles("game/actors")) do
    if actor:sub(-4) == ".lua" then
        require("game/actors/" .. actor:sub(1, -5))
    end
end
