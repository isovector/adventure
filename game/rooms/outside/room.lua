tmp_anims = {}
tmp_anims.sign = animation.build_set(get_bitmap("game/rooms/outside/objects/sign.pcx"), 1, 2, 0, 0)
tmp_anims.sign.anims.stand = {
    { duration = 3, frame = 0 },
    { duration = 0.3, frame = 1 },
    { duration = 0.1, frame = 0 },
    { duration = 0.1, frame = 1 },
    { duration = 1, frame = 0 },
    { duration = 0.2, frame = 1 }
}

local room = rooms.create("outside")

room.place(actors.gomez)
room.place(actors.shaggy)
room.place(actors.bouncer)
room.place(actors.diondre)
room.place(actors.waldo)

room.place(actors.temp("sign", "Sign", animation.start(tmp_anims.sign, "stand"), 1), vec(940, 156))
room.place(actors.temp("cup", "Milkshape Cup", "game/rooms/outside/objects/cup.pcx"), vec(830, 436))
room.place(actors.temp("sword", "Sword", "game/rooms/outside/objects/sword.pcx"), vec(110, 445))
room.place(actors.temp("note", "Note", "game/rooms/outside/objects/letter.pcx"), vec(580, 97))
room.place(actors.temp("rope", "Rope", "game/rooms/outside/objects/rope.pcx"), vec(910, 494))

room.hotspot(34, "window", "Window");
room.hotspot(68, "sign", "Sign");
room.hotspot(85, "rear", "Back Alley");
room.hotspot(102, "ladder", "Ladder");
room.hotspot(119, "rope", "Rope");

room.events.load.sub(function()
    room.foreground(17, 54)
    room.door(17, "door", "Door", "outside", 17, 8)
end)

room.hotspots.window.look.sub(function()
    player.say("I can't reach it")
end)

room.hotspots.ladder.touch.sub(function()
    player.say("That won't fit in my pants")
end)