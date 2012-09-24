require "classes/room"
require "classes/sandbox"
require "assets/actors/actors"

local function buildRoom(name)
    local path = "assets/rooms/" .. name

    local room = Room.new(name, path .. "/art.png")
    room.directory = path

    local pathing = require(path .. "/pathfinding")
    room:installPathing(pathing)
    
    local hotspots = require(path .. "/hotspots")
    hotspots(room)

    local actors = require(path .. "/actors")
    actors(room)
    
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

for _, room in ipairs(MOAIFileSystem.listDirectories("assets/rooms")) do
    buildRoom(room:sub(14))
end
