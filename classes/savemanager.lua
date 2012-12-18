mrequire "classes/class"
mrequire "classes/scaffoldtable"

newclass("SaveManager",
    function()
        return { }
    end
)

local gamedata = { }
local function saveVal(crumbs, val)
    gamedata[table.concat(crumbs, "/")] = val
end

local function loadVal(crumbs)
    return gamedata[table.concat(crumbs, "/")]
end

function SaveManager:install()
    gamedata = { }
    local save = ScaffoldTable.new(saveVal, loadVal)
    _G.save= save
end
