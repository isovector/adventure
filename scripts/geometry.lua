function rotate(v, rot)
    rot = rot * math.pi / 128
    local cos = math.cos(rot)
    local sin = math.sin(rot)
    
    return vector(cos * v.x - sin * v.y, sin * v.x + cos * v.y)
end

function interp(errorval)
    if errorval == nil then
        errorval = 0
    end

    local terpo = { 
        error_value = errorval,
        round = true
    }
    
    setmetatable(terpo, {
        __index = function(tab, index)
            local keys = { }
            
            for key in pairs(tab) do
                if key ~= "error_value" and key ~= "round" then
                    table.insert(keys, key)
                end
            end
            
            table.sort(keys)
        
            for i=0, table.getn(keys) do
                local here = keys[i]
                local next = keys[i + 1]
                
                if here and next then
                    if here <= index and index <= next then
                        local size = next - here
                        local perc = (index - here) / size
                        
                        here = tab[here]
                        next = tab[next]
                        size = next - here
                        
                        local val = size * perc + here
                        
                        if tab.round then
                            val = math.floor(val)
                        end
                        
                        return val
                    end
                elseif (not here and index <= next)
                    or (not next and here <= index) then
                    return tab.error_value
                end
            end
        end
    })
    
    return terpo
end

function in_ellipse(origin, size, point)
    local d = point - origin
    return (d.x * d.x) / (size.x * size.x) + (d.y * d.y) / (size.y * size.y) <= 1
end