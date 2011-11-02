dofile("game/actors/waldo/animation.lua")

local actor = actors.create("waldo", "Waldo Gembara", animation.start(animations.waldo, "stand"), 1)
actor.pos = vec(100, 160)
actor.color = 0xFFFFF