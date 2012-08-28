require "assets/costumes/costumes"

for _, path in ipairs(MOAIFileSystem.listDirectories("assets/actors")) do
    require(path .. "/actor")
end
