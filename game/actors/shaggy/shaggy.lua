dofile("game/actors/shaggy/animation.lua")

actors.shaggy = {
        id = "shaggy",
        name = "Shaggy",
        ignore_ui = false,
        pos = {x = 540, y = 280},
        color = 255255,
        speed = 100,
        goal = nil,
        goals = {},
        inventory = {},
        flipped = false,
        aplay = animation.start(animations.shaggy, "stand")
    }
 
