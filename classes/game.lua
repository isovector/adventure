game = { }

local function exportTable(t)
    for name, func in pairs(t) do
        game.export(name, func)
    end
end

function game.export(name, func)
    if not func and type(name) == "table" then
        exportTable(name)
        return
    end
    
    rawset(game, name, func)
end

setmetatable(game, {
    __newindex = function() error("Call game.export() to add methods") end,
    __index = function(t, k) error(k .. " hasn't been exported. Check your requires and spelling") end
})
