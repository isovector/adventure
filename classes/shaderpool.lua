require "classes/class"
require "classes/fragmentshader"

local vshPool = { }
local fshPool = { }

newclass("ShaderPool", false)

function ShaderPool.addVsh(id)
    file = io.open(string.format("assets/shaders/%s.vsh", id))
    local shader = file:read('*all')
    file:close()
    
    vshPool[id] = shader
end

function ShaderPool.addFsh(id)
    file = io.open(string.format("assets/shaders/%s.fsh", id))
    local shader = file:read('*all')
    file:close()
    
    fshPool[id] = FragmentShader.new(shader)
end

function ShaderPool.getVsh(id)
    return vshPool[id]
end

function ShaderPool.getFsh(id)
    return fshPool[id]
end
