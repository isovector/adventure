mrequire "src/game/room"
mrequire "src/engine/scaffoldtable"

local function buildEvent(crumbs, key, value, room)
    local id = table.concat(crumbs, "_")
    
    if not room.events[id] then
        room.events[id] = { }
    end
    
    room.events[id][key] = value
end

local function buildRoom(name)
    local path = "game/rooms/" .. name

    if not MOAIFileSystem.checkFileExists(path .. "/art.png") then
        return
    end
    
    local room = Room.new(name, path .. "/art.png")
    room.directory = path
    
    if MOAIFileSystem.checkFileExists(path .. "/pathfinding.lua") then
        local pathing = require(path .. "/pathfinding")
        room:installPathing(pathing)
    end
    
    if MOAIFileSystem.checkFileExists(path .. "/hotspots.lua") then
        require(path .. "/hotspots")(room)
    end

    if MOAIFileSystem.checkFileExists(path .. "/actors.lua") then
        require(path .. "/actors")(room)
    end
    
    if MOAIFileSystem.checkFileExists(path .. "/script.lua") then
        room.onLoad = function()
            room.events = { }
            
            events = ScaffoldTable.new(buildEvent, nil, true, room)
            dofile(path .. "/script.lua")
            events = nil
        end
    end
end

game:add("loadRoom", buildRoom)

for _, room in ipairs(MOAIFileSystem.listDirectories("game/rooms")) do
    buildRoom(room)
end

