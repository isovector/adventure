mrequire "src/engine/shader"

for _, shader in ipairs(MOAIFileSystem.listFiles("game/shaders")) do
    local name = shader:sub(1, -5)
    if shader:sub(-4) == ".fsh" then
        Shader.registerFsh(name)
    elseif shader:sub(-4) == ".vsh" then
        Shader.registerVsh(name)
    end
end
