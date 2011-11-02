dofile("game/actors/gomez/animation.lua")

local actor = actors.create("gomez", "Gomez Lupe", animation.start(animations.gomez, "stand"), 1)
actor.ignore_ui = true
actor.pos = vec(600, 500)
actor.color = 0xFF8800