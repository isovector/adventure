require "assets/actors/actors"
require "classes/room"

local room = Room.new("inside", "assets/rooms/inside/art.png")
local pathing = require "assets/rooms/inside/pathfinding"

print(#pathing.map[1], #pathing.map)

room:installPathing(pathing)

room:addActor(Actor.getActor("santino"), 900, 600)
