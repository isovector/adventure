--- Utility class to parse fragment shaders and export uniform information.

mrequire "src/class"

--- The FragmentShader class.
-- This is an internal class used by Shader and as such should probably
-- never be used in user code.
-- Constructor signature is (code).
-- @newclass FragmentShader
newclass("FragmentShader",
    function(code)
        local uniforms = { }
        local uniformCount = 0
    
        for line in code:gmatch("[^\r\n]+") do
            local utype, uname = line:match("uniform ([A-Za-z0-9]+) ([A-Za-z0-9]+);")
            if utype and utype ~= "sampler2D" then
                if utype == "float" or utype == "int" then
                    uniformCount = uniformCount + 1
                    uniforms[uname] = { type = utype, index = uniformCount }
                else
                    error(string.format("FragmentShader doesn't support %s uniforms", utype))
                end
            end
        end
        
        return { 
            code = code,
            uniforms = uniforms,
            uniformCount = uniformCount
        }
    end
)
