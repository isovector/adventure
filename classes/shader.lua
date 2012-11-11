require "classes/class"
require "classes/shaderpool"
require "classes/fragmentshader"

local function fragmentAssignment(self, key, value)
    local uni = self.__shader.fsh.uniforms[key]
    self.__shader:setUniform(key, uni, value)
end

newclass("Shader",
    function(vsh, fsh)
        vsh = ShaderPool.getVsh(vsh)
        fsh = ShaderPool.getFsh(fsh)
    
        local shader = MOAIShader.new()
        shader:load(vsh, fsh.code)
        
        local self = {
            shader = shader,
            vsh = vsh,
            fsh = fsh
        }
        
        shader:reserveUniforms(fsh.uniformCount)
        for uname, uni in pairs(fsh.uniforms) do
            if uni.type == "float" then
                shader:declareUniformFloat(uni.index, uname, 0)
            else
            end
        end
        
        shader:setVertexAttribute(1, 'position')
        shader:setVertexAttribute(2, 'uv')
        
        self.fragment = setmetatable({ __shader = self }, { __newindex = fragmentAssignment })
        
        return self
    end
)

function Shader:setUniform(name, uni, value)
    self.shader:clearUniform(uni.index)
    if uni.type == "float" then
        self.shader:declareUniformFloat(uni.index, name, value)
    else
    end
end

function Shader:applyTo(prop)
    prop:setShader(self.shader)
    prop.shader = self
end
