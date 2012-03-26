dofile("game/actors/waldo/animation.lua")

local actor = actors.create("waldo", "Waldo Gembara", animation.start(animations.waldo, "stand"), 1)
actor.pos = vector(100, 160)
actor.color = 0xFFFFF