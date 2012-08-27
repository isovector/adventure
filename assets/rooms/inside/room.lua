local name = "inside"
local path = "assets/rooms/" .. name

require "assets/actors/actors"
require "classes/room"

local room = Room.new(name, path .. "/art.png")
room.directory = path

local pathing = require(path .. "/pathfinding")
room:installPathing(pathing)

room:addActor(Actor.getActor("santino"), 900, 600)
