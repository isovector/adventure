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

function table.find(tab, predicate)
    for key, val in ipairs(tab) do
        if predicate(key, val) then
            return val
        end
    end

    for key, val in pairs(tab) do
        if predicate(key, val) then
            return val
        end
    end
    
    return nil
end

function table.contains(tab, value)
    for key, val in ipairs(tab) do
        if val == value then
            return key
        end
    end

    return false
end

function table.car(tab)
    if type(tab) ~= "table" then return tab end
    if not tab then return nil end

    return tab[1]
end

function table.serialize(tab, indent, open)
    if not indent then
        indent = ""
        open = {}
    end

    local output = "{ "

    table.insert(open, tab)

    for key, val in pairs(tab) do
        local out = val
        if type(val) == "table" then
            --if not table.contains(open, val) then
                out = table.serialize(val, indent, open)
            --else
                --out = "{RECURSION}"
            --end
        elseif type(val) == "string" then
            out = "\"" .. val .. "\""
        elseif type(val) == "function" then
            out = "function"
        elseif type(val) == "userdata" then
            out = "userdata"
        elseif type(val) == "nil" then
            out = "nil"
        elseif type(val) == "boolean" then
            if val then out = "true" else out = "false" end
        end

        output = output .. key .. "=" .. out .. ", "
    end

    output = string.sub(output, 1, -2)

    return output .. " }"
end

function table.cdr(tab)
    if not tab or type(tab) ~= "table" then return nil end

    local cdr = {}
    local first = true

    for key, val in ipairs(tab) do
        if not first then
            table.insert(cdr, val)
        else
            first = false
        end
    end

    if table.getn(cdr) == 0 then return nil end
    return cdr
end

function math.clamp(val, low, high)
    return math.max(low, math.min(high, val))
end

vector = {}

function vec(a, b) 
    if b then
        return { x = a, y = b }
    end
    
    return { x = a, y = a }
end

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
