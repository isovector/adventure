-{ block:

    -- [x, y] => x + y
    mlp.expr:add{ "[", mlp.expr, ",", mlp.expr, "]", 
        builder = |x| +{ -{x[1]} + -{x[2]} } }
}

print([5, 6])
local f = |x| x + 15
print(f(15))
