--- Provides a high-level wrapper around MOAI's Shaders.
-- Encorporates both VSHes and FSHes into one object.

mrequire "classes/class"
require "classes/fragmentshader"

--- Helper function to assign uniforms on fragment shaders
-- @param self The Shader's fragment table
-- @param key The uniform name
-- @param value The desired value
local function fragmentAssignment(self, key, value)
    local uni = self.__shader.fsh.uniforms[key]
    self.__shader:setUniform(key, uni, value)
end

local vshPool = { }
local fshPool = { }

--- The Shader class.
-- Constructor signature is (vsh, fsh).
-- Both vsh and fsh should be basenames of files in /assets/shaders.
-- The fragment index contains the uniforms in the FSH, and may be assigned to for convenience.
-- @newclass Shader
newclass("Shader",
    function(vsh, fsh)
        vsh = vshPool[vsh]
        fsh = fshPool[fsh]
    
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
            elseif uni.type == "int" then
                shader:declareUniformInt(uni.index, uname, 0)
            else
            end
        end
        
        shader:setVertexAttribute(1, 'position')
        shader:setVertexAttribute(2, 'uv')
        
        self.fragment = setmetatable({ __shader = self }, { __newindex = fragmentAssignment })
        
        return self
    end
)

--- Helper method to register a vertex shader. 
-- Called by the 1-load-shaders.lua service.
-- @param id
function Shader.registerVsh(id)
    file = io.open(string.format("assets/shaders/%s.vsh", id))
    local shader = file:read('*all')
    file:close()
    
    vshPool[id] = shader
end

--- Helper method to register a fragment shader. 
-- Called by the 1-load-shaders.lua service.
-- @param id
function Shader.registerFsh(id)
    file = io.open(string.format("assets/shaders/%s.fsh", id))
    local shader = file:read('*all')
    file:close()
    
    fshPool[id] = FragmentShader.new(shader)
end

--- Wrapper around MOAI's setUniform interface.
-- This should never be called by user code.
-- @param name The uniform name
-- @param uni The uniform object
-- @param value The new value for uniform
function Shader:setUniform(name, uni, value)
    self.shader:clearUniform(uni.index)
    if uni.type == "float" then
        self.shader:declareUniformFloat(uni.index, name, value)
    elseif uni.type == "int" then
        self.shader:declareUniformInt(uni.index, uname, 0)
    else
    end
end

--- Applies a shader to a MOAI prop.
-- @param prop
function Shader:applyTo(prop)
    prop:setShader(self.shader)
    prop.shader = self
end
