rect = { }
geometry = {
    vector_mt = {
        __add = function(op1, op2)
                return vec(op1.x + op2.x, op1.y + op2.y)
            end,
        __sub = function(op1, op2)
                return vec(op1.x - op2.x, op1.y - op2.y)
            end,
        __mul = function(op, k)
                return vec(op.x * k, op.y * k)
            end,
        __eq = function(op1, op2)
                return op1.x == op2.x and op1.y == op2.y
            end,
        __index = function(tab, key)
                if key == "normal" then
                    return function()
                        local len = tab.len()
                        return vec(tab.x / len, tab.y / len)
                    end
                elseif key == "len" then
                    return function()
                        return math.sqrt(tab.x * tab.x + tab.y * tab.y)
                    end
                elseif key == "x" then
                    return tab.x
                elseif key == "y" then
                    return tab.y
                end
                
            end
    }
}

function rect.create(pos, size, w, h)
    if w then
        pos = vec(pos, size)
        size = vec(w, h)
    end
    
    local outrect = {
        pos = pos,
        size = size
    }
        
    outrect.contains = function(pos)
        return  outrect.pos.x < pos.x
            and outrect.pos.y < pos.y
            and outrect.pos.x + outrect.size.x > pos.x
            and outrect.pos.y + outrect.size.y > pos.y
    end
        
    outrect.intersects = function(other)
        local r1 = outrect.pos
        local r2 = other.pos
    
        return not(r1.x > r2.x + other.size.x
                or r2.x > r1.x + outrect.size.x
                or r1.y > r2.y + other.size.y
                or r2.y > r1.y + outrect.size.y)
    end
    
    return outrect
end

function vec(a, b) 
    local val = { x = a, y = a }

    if b then
        val = { x = a, y = b }
    elseif type(a) == "table" then
        val = { x = a.x, y = a.y }
    end
    
    setmetatable(val, geometry.vector_mt)
    
    return val
end

function rotate(v, rot)
    rot = rot * math.pi / 128
    local cos = math.cos(rot)
    local sin = math.sin(rot)
    
    return vec(cos * v.x - sin * v.y, sin * v.x + cos * v.y)
end

function interp()
    local terpo = { 
        error_value = 0,
        round = true
    }
    
    setmetatable(terpo, {
        __index = function(tab, index)
            local keys = { }
            
            table.sort(tab)
            
            for key in pairs(tab) do
                if key ~= "error_value" and key ~= "round" then
                    table.insert(keys, key)
                end
            end
        
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
