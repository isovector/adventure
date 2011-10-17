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

function vec(a, b) 
    local val = { x = a, y = a }

    if b then
        val = { x = a, y = b }
    elseif type(a) == "table" then
        -- only process things we need to
        if not getmetatable(a) then
            val = { x = a.x, y = a.y }
        else
            return a
        end
    end
    
    setmetatable(val, {
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
    })
    
    return val
end

