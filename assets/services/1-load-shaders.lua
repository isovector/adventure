require "classes/shaderpool"

for _, shader in ipairs(MOAIFileSystem.listFiles("assets/shaders")) do
    local name = shader:sub(16, -5)
    if shader:sub(-4) == ".fsh" then
        ShaderPool.addFsh(name)
    elseif shader:sub(-4) == ".vsh" then
        ShaderPool.addVsh(name)
    end
end
