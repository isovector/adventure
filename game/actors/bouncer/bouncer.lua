dofile("game/actors/bouncer/animation.lua")

local actor = actors.create("bouncer", "Bouncer", animation.start(animations.bouncer, "stand"), 1)
actor.pos = vector(1050, 600)
actor.color = 255000
actor.origin.y = actor.origin.y * 0.9