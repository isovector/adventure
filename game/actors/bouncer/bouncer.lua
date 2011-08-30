dofile("game/actors/bouncer/animation.lua")

actors.bouncer = {
        id = "bouncer",
        name = "Bouncer",
        pos = {x = 1050, y = 600},
        color = 255000,
        speed = 150,
        inventory = {},
        flipped = true,
        aplay = animation.start(animations.bouncer, "stand")
    }

