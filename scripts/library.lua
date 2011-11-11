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

function math.ipart(value)
    return value - math.mod(value, 1)
end

function math.fpart(value)
    return math.mod(value, 1)
end

function math.round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end
