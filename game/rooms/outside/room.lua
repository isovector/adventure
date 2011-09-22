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

room = {
    scene = {
        actors.gomez, actors.shaggy, actors.bouncer
    },
    events = {}
}

dofile("game/rooms/outside/objects/objects.lua")

function room.on_init()
    table.insert(room.scene, room.objects.sign)
    table.insert(room.scene, room.objects.cup)
    table.insert(room.scene, room.objects.sword)
    table.insert(room.scene, room.objects.note)
    table.insert(room.scene, room.objects.rope)
    
    register_foreground(17, 540)
end

function room.on_load()
    print("loaded test2")
    
    register_hotspot(17, "door", "Door");
    register_door("door", "outside", 51, 8)
    register_hotspot(34, "window", "Window");
    register_hotspot(51, "drain", "Drain Pipe");
    register_door("drain", "outside", 17, 3)
    register_hotspot(68, "sign", "Sign");
    register_hotspot(85, "rear", "Back Alley");
    register_hotspot(102, "ladder", "Ladder");
    register_hotspot(119, "rope", "Rope");
end

function room.events.sword_look()
    say(player, "There's a sword sticking out of this wall")
    say(player, "I wonder what this wall is made of...")
end

function room.events.sword_touch()
    say(player, "I'll just... liberate this")
    room.scene.sword = nil
	table.remove(room.scene, table.contains(room.scene, room.objects.sword))
end

function room.events.note_look()
    say(player, "A note is mounted here")
    say(player, "\"SANDY IS COOL\"")
    say(player, "I'd believe that")
end

function room.events.note_touch()
    say(player, "I'll just... liberate this")
    table.remove(room.scene, table.contains(room.scene, room.objects.note))
end

function room.events.cup_look()
    say(player, "It's an old milkshape cup.")
end

function room.events.cup_touch()
    say(player, "THE GARBAGE MAN IS HERE")
    table.remove(room.scene, table.contains(room.scene, room.objects.cup))
end

function room.events.sign_look()
    say(player, "It says \"Flannigans\"")
    say(player, "This is my favorite pub")
end

function room.events.sign_touch()
    say(player, "I can't reach it!")
end

function room.events.window_touch()
    say(player, "I can't reach it!")
end

function room.events.rope_touch()
    say(player, "I can't reach it!")
end

function room.events.rope_sword()
    say(player, "That's a good idea, but my arm isn't that long")
    say(player, "Maybe I should try cutting a closer rope?")
end

function room.events.rope_look()
    say(player, "It's a rope to keep the bouncer clear")
end

function room.events.rear_look()
    say(player, "It's the back alley. I can't get to there")
end

function room.events.drain_look()
    say(player, "Hey! Now THIS is a nice drain pipe!")
end

function room.events.ladder_look()
    say(player, "There is a conveniently placed ladder here")
end

function room.events.ladder_touch()
    say(player, "I can't put THAT in my pants!")
end
