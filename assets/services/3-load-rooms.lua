require "classes/room"
require "classes/game"
require "classes/sandbox"

local function buildRoom(name)
    local path = "assets/rooms/" .. name

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
            local sb = Sandbox.new()
            
            for id, actor in pairs(room.scene) do
                sb:addValue(id, actor.actor)
            end
            
            for _, hs in ipairs(room.hotspots) do
                sb:addValue(hs.id, hs)
            end
            
            sb:dofile(path .. "/script.lua")
            
            room.events = sb:getResults()
        end
    end
end

game.export("loadRoom", buildRoom)

for _, room in ipairs(MOAIFileSystem.listDirectories("assets/rooms")) do
    buildRoom(room:sub(14))
end

