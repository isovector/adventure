require "classes/actor"

for _, actor in ipairs(MOAIFileSystem.listFiles("assets/actors")) do
    if actor:sub(-4) == ".lua" then
        require("assets/actors/" .. actor:sub(1, -5))
    end
end
