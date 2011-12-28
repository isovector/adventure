tmp_anims = {}
tmp_anims.sign = animation.build_set(bitmap("game/rooms/outside/objects/sign.pcx"), 1, 2, 0, 0)
tmp_anims.sign.anims.stand = {
    { duration = 3, frame = 0 },
    { duration = 0.3, frame = 1 },
    { duration = 0.1, frame = 0 },
    { duration = 0.1, frame = 1 },
    { duration = 1, frame = 0 },
    { duration = 0.2, frame = 1 }
}



local room = rooms.create("outside")

load_module("rooms/outside/dialogue.lua")

room.place(actors.gomez)
room.place(actors.bouncer)
actors.bouncer.flipped = true

--local cup = actors.temp("cup", "Milkshape Cup", "game/rooms/outside/objects/cup.pcx")

--room.place(actors.temp("sign", "Sign", animation.start(tmp_anims.sign, "stand"), 1), vec(940, 156))
--room.place(cup, vec(830, 436))
--room.place(actors.temp("sword", "Sword", "game/rooms/outside/objects/sword.pcx"), vec(110, 445))
--room.place(actors.temp("note", "Note", "game/rooms/outside/objects/letter.pcx"), vec(580, 97))
--room.place(actors.temp("rope", "Rope", "game/rooms/outside/objects/rope.pcx"), vec(910, 494))

room.hotspot(34, "window", "Window");
room.hotspot(68, "sign", "Sign");
room.hotspot(85, "rear", "Back Alley");
room.hotspot(102, "ladder", "Ladder");
room.hotspot(119, "rope", "Rope");

room.door(17, "door", "Pub Entrance", "outside", 68, 8)


actors.bouncer.events.talk.sub(function()
    open_topic(room.dialogue.bouncer)
end)


room.hotspots.window.events.look.sub(function()
    player.say("I can't reach it")
end)

room.hotspots.ladder.events.touch.sub(function()
    player.say("That won't fit in my pants")
end)

--[[cup.events.touch.sub(function()
    print("hello")
    player.say("Hey! This is beer!")
    player.say("Score!")
    player.obtain_item("beer")
end)]]
