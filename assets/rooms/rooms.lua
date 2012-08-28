require "assets/actors/actors"
require "classes/room"

local function buildRoom(name)
    local path = "assets/rooms/" .. name

    local room = Room.new(name, path .. "/art.png")
    room.directory = path

    local pathing = require(path .. "/pathfinding")
    room:installPathing(pathing)

    local actors = require(path .. "/actors")
    actors(room)
end

for _, room in ipairs(MOAIFileSystem.listDirectories("assets/rooms")) do
    buildRoom(room:sub(14))
end
