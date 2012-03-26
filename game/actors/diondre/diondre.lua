dofile("game/actors/diondre/animation.lua")

local actor = actors.create("diondre", "Diondre Morgan", animation.start(animations.diondre, "stand"), 1)
actor.pos = vector(200, 700)
actor.color = 0x0000FF