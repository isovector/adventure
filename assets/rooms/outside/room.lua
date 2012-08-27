local name = "outside"
local path = "assets/rooms/" .. name

require "assets/actors/actors"
require "classes/room"

local room = Room.new(name, path .. "/art.png")
room.directory = path

local pathing = require(path .. "/pathfinding")
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

room:addActor(Actor.getActor("santino"), 700, 400)