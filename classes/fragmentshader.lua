mrequire "classes/class"

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
