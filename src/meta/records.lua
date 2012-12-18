-{ block:

local function getName(list, append)
    local name = ""
    
    for i = 2, #list do
        name = name .. "/" .. list[i][1]
    end
    
    if append then
        return name .. "/"
    end
    
    return name
end

local function getAST(list, append)
    local name = `String { getName(list, append) }
    
    if append then
        name = `Op { "concat", name, append }
    end

    return `Index { `Id { list[1][1] }, name }
end

local function recget(x)
    return getAST(unpack(x))
end

local function recset(x)
    local list, val, expr = unpack(x)
    
    return `Set { { getAST(list, val) }, { expr} }
end

mlp.lexer:add { "record" }

local slashList = gg.list{ mlp.id, separators = "/"}
mlp.expr.primary = gg.multisequence { mlp.expr.primary,  gg.sequence{"/", slashList, builder = recget } }
mlp.stat:add { "record", "/", slashList, gg.onkeyword{",", mlp.expr}, "=", mlp.expr, builder = recset } 


--------------------------------------------------------------------

mlp.expr.prefix:add { "*", prec = 100, builder = |_, x| `Invoke { x, `String { "__deref" } } }

}
