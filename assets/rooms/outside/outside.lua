require "classes/room"

local room = Room.new("outside", "assets/rooms/outside/art.png")
local pathing = require "assets/rooms/outside/pathfinding"

print(#pathing.map[1], #pathing.map)

room:installPathing(pathing)

room:addHotspot(Hotspot.new("stop", 5, "Stop!", 
    546, 406, 
    572, 407, 
    585, 423, 
    586, 441, 
    576, 456, 
    549, 453, 
    536, 440, 
    538, 415
))
