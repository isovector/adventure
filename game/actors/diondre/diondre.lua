dofile("game/actors/diondre/animation.lua")

actors.diondre = {
        id = "diondre",
        name = "Diondre Morgan",
        pos = {x = 200, y = 700},
        color = 255000,
        speed = 110,
        inventory = {},
        flipped = false,
        aplay = animation.start(animations.diondre, "stand")
    }

