local room = Room.new("outside", load.image("game/rooms/outside/art.pcx"), load.image("game/rooms/outside/hot.pcx"))

load.module("rooms/outside/dialogue.lua")

room:place(actors.santino)
room:door(17, "door", "Pub Entrance", "outside", 68, 8)
room:foreground(17, 600)
