dofile("game/actors/shaggy/animation.lua")

local actor = actors.create("shaggy", "Shaggy", animation.start(animations.shaggy, "stand"), 1)
actor.pos = vector(540, 280)
actor.color = 0x00FFFF