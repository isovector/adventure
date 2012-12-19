-- from http://metalua.blogspot.ca/2007/12/code-walkers.html

-{ extension 'match' }
-{ extension 'log' }

-{ block:

require "metalua.walk"

-----------------------------------------------------------------------------

Reference = { `Pair{ `String "tag", `String "Reference" } }

-----------------------------------------------------------------------------

scope = { }
scope.__index = scope

function scope:new()
    local ret = { current = { } }
    ret.stack = { ret.current }
    setmetatable (ret, self)
    return ret
end

function scope:push(...)
    table.insert (self.stack, table.shallow_copy (self.current))
    if ... then return self:add(...) end
end

function scope:pop()
    self.current = table.remove (self.stack)
end

function scope:add (name, val)
    self.current[name] = val
end

-----------------------------------------------------------------------------

local refs = scope:new()

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
        | `Function{ params, _ } -> scope.push(refs)
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
        | `Forin{ vars, ... }    -> scope.push(refs)
        | `Fornum{ var, ... }    -> scope.push(refs)
        | `Localrec{ vars, ... } -> -- pass
        | `Local{ ... }          -> -- pass
        | `Call { ... }          ->   name = x[1][1]
                                    if name:sub(1, 5) == ".$REF" then
                                        scope.add(refs, name:sub(6), x[2])
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
        | `Local{ vars, ... }            -> -- pass
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

local function ref_builder(x)
    lhs, rhs = unpack(x)
    return `Call { `Id{ ".$REF" .. lhs[1][1]}, rhs[1] }
end

mlp.chunk.transformers:add (chunk_transformer)
mlp.lexer:add { "reference" }
mlp.stat:add { "reference", gg.list { mlp.id, separators = "," }, "=", gg.list { mlp.expr, separators = ","}, builder = ref_builder }

}
