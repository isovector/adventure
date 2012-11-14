for _, path in ipairs(MOAIFileSystem.listDirectories("assets/actors")) do
    require("assets/actors/" .. path .. "/actor")
end
