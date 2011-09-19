 
room.objects = {
        sign = {
            id = "sign",
            ignore_ui = true,
            pos = {x = 940, y = 156}, 
            aplay = animation.start(tmp_anims.sign, "stand")
        },
        cup = {
            id = "cup",
            name = "Milkshake Cup",
            pos = {x = 830, y = 436}, 
            sprite = get_bitmap("game/rooms/outside/objects/cup.pcx")
        },
        sword = {
            id = "sword",
            name = "Sword",
            pos = {x = 110, y = 445}, 
            sprite = get_bitmap("game/rooms/outside/objects/sword.pcx")
        },
        note = {
            id = "note",
            name = "Note",
            pos = {x = 580, y = 97}, 
            sprite = get_bitmap("game/rooms/outside/objects/letter.pcx")
        },
        rope = {
            id = "rope",
            name = "Rope",
            pos = {x = 910, y = 494}, 
            sprite = get_bitmap("game/rooms/outside/objects/rope.pcx"),
            height = 128
        }
    }