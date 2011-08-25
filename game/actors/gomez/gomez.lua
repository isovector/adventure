dofile("game/actors/gomez/animation.lua")

actors.gomez = {
    id = "gomez",
    name = "Gomez",
    ignore_ui = true,
    pos = {x = 600, y = 500},
    color = 255,
    speed = 150,
    goal = nil,
    goals = {},
    events = {},
    inventory = {},
    flipped = false,
    aplay = animation.start(animations.gomez, "stand")
}