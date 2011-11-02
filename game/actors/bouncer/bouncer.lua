dofile("game/actors/bouncer/animation.lua")

local actor = actors.create("bouncer", "Bouncer", animation.start(animations.bouncer, "stand"), 1)
actor.pos = vec(1050, 600)
actor.color = 255000