--- Provides the import() and reference constructs to the language via metalua.
-- ldoc fails to parse metalua correctly.

-{ extension 'match' }
-{ extension 'log' }

-{ block:

require "metalua.walk"

-----------------------------------------------------------------------------
;
local scope = { }
scope.__index = scope

function scope:new()
    local ret = { current = { } }
    ret.stack = { ret.current }
    setmetatable (ret, self)
    return ret
end

function scope:push()
    table.insert (self.stack, table.shallow_copy (self.current))
end

function scope:pop()
    self.current = table.remove (self.stack)
end

function scope:add(vars)
    for id in values (vars) do
        if id.tag == "Id" then
            self.current[id[1]] = false
        end
    end
end

function scope:addRef(name, replacement)
    self.current[name] = replacement
end

-----------------------------------------------------------------------------
;
local refs = scope:new()

-- from http://metalua.blogspot.ca/2007/12/code-walkers.html

--- Maintains scope information and replaces references.
local function chunk_transformer (term)
    local refs    = refs:new()
    local cfg = { expr  = { },
                 stat  = { },
                 block = { } }

    -----------------------------------------------------------------------------
    -- Check identifiers; add functions parameters to newly created refs.
    -----------------------------------------------------------------------------
    function cfg.expr.down(x)
        match x with
        | `Function{ params, _ } -> scope.push(refs); scope.add(refs, params)
        | _ -> -- pass
        end
    end

    -----------------------------------------------------------------------------
    -- Close the function refs opened by 'down()'.
    -----------------------------------------------------------------------------
    function cfg.expr.up(x)
        match x with
        | `Function{...} -> scope.pop(refs)
        | `Id{ ... }     -> name = x[1]
                            local rep = refs.current[name]
                            if rep then
                                x <- rep
                            end
        | _ -> --pass
        end
    end

    -----------------------------------------------------------------------------
    -- Create a new refs and register loop variable[s] in it
    -----------------------------------------------------------------------------
    function cfg.stat.down(x)
        match x with
        | `Forin{ vars, ... }    -> scope.push(refs); scope.add(refs, vars)
        | `Fornum{ var, ... }    -> scope.push(refs); scope.add(refs, { var })
        | `Localrec{ vars, ... } -> scope.add(refs, vars)
        | `Local{ ... }          -> -- pass
        | `Call { ... }          ->   name = x[1][1]
                                    if type(name) == "string" and name:sub(1, 5) == ".$REF" then
                                        scope.addRef(refs, name:sub(6), x[2])
                                        x <- `Local { { `Id { "_" } }, { `Nil } }
                                    end
        | _ -> --pass
        end
    end

    -----------------------------------------------------------------------------
    -- Close the refss opened by 'up()'
    -----------------------------------------------------------------------------
    function cfg.stat.up(x)
        match x with
        | `Forin{ ... } | `Fornum{ ... } -> scope.pop(refs)
        | `Local{ vars, ... }            -> scope.add(refs, vars)
        | `Localrec{ ... }               -> -- pass
        | _ -> --pass
        end
    end

    -----------------------------------------------------------------------------
    -- Create a separate refs for each block, close it when leaving.
    -----------------------------------------------------------------------------
    function cfg.block.down() scope.push(refs) end
    function cfg.block.up()   scope.pop(refs) end

    walk.block(cfg, term)
end

--- Builds the lua AST for a reference declaration.
-- @param x A matching reference AST
local function ref_builder(x)
    lhs, rhs = unpack(x)
    return `Call { `Id{ ".$REF" .. lhs[1][1]}, rhs[1] }
end

--- Builds the lua AST for an import declaration.
-- @param x A matching import AST
local function import_builder(x)
    locals, source = unpack(x)
    
    local result = { }
    
    local index
    for id in values(source) do
        if id[1] then
            if not index then
                index = id
            else
                index = `Index { index, `String { id[1] } }
            end
            
            table.insert(result, `If { `Op { "eq", index, `Nil },  { `Set { { index }, { `Table { } } } } })
        end
    end
    
    for import in values(locals) do
        local id = import[1]
        local value = import[2]
        if id and id[1] then
            local index = `Index { index, `String { id[1] } }
            table.insert(result, `If { `Op { "eq", index, `Nil },  { `Set { { index }, { value[1] or `Nil } } } })
            table.insert(result, `Call { `Id{ ".$REF" .. id[1]}, index })
        end
    end
    
    
    return result
end

mlp.chunk.transformers:add (chunk_transformer)
mlp.lexer:add { "reference", "import", "from" }
mlp.stat:add { "reference", gg.list { mlp.id, separators = "," }, "=", gg.list { mlp.expr, separators = ","}, builder = ref_builder }


mlp.stat:add { "import", gg.list { gg.sequence { mlp.id, gg.multisequence { { }, { "=", mlp.expr } } }, separators = "," }, "from", gg.list { mlp.id, separators = "." }, builder = import_builder }

}

