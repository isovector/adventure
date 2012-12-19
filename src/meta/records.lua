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

local function persistence(x)
    lhs, rhs = unpack(x)
    assert(#lhs == #rhs)
    return `Local { lhs, rhs }
end

mlp.lexer:add { "=>", "persist" }

mlp.stat:add { "persist", gg.list { mlp.id, separators = "," }, "=", gg.list { mlp.expr, separators = ","}, builder = persistence }

mlp.stat.assignments["=>"] = function(lexpr, rexpr)
    assert(#lexpr == 1 and #rexpr == 1)
    local left, right = lexpr[1], rexpr[1]
    return `Invoke { left, `String { "__assign" }, right }
end

mlp.expr.prefix:add { "*", prec = 100, builder = |_, x| `Invoke { x, `String { "__deref" } } }

}
