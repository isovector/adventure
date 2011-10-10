dofile("game/actors/waldo/animation.lua")

actors.waldo = {
        id = "waldo",
        name = "Waldo Gembara",
        pos = {x = 100, y = 160},
        color = 255000,
        speed = 110,
        inventory = {},
        flipped = false,
        aplay = animation.start(animations.waldo, "stand")
    }

