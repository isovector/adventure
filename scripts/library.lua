pqueue = {}

function pqueue.enqueue(tab, priority, value)
    table.insert(tab, {priority, value});
end

function pqueue.dequeue(tab)
    local max, pos
    
    for key, val in ipairs(tab) do
        if not max or val[1] > max then
            pos = key
            max = val[1]
        end
    end
    
    if not tab[pos] then return nil end
    
    max = tab[pos][2]
    table.remove(tab, pos)
    
    return max
end

function table.contains(tab, value) 
    for key, val in ipairs(tab) do
        if val == value then
            return true
        end
    end
    
    return false
end

vector = {}

function vector.length(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

function vector.diff(a, b)
    return {x = b.x - a.x, y = b.y - a.y}
end

function vector.normal(v)
    local len = vector.length(v)
    return {x = v.x / len, y = v.y / len}
end