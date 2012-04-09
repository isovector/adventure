local cost = nil
cost = costume.create()
cost.poses = {
	idle = {
		5 = animation.create(load.bitmap("game/costumes/santino/idle5.png"), 24, 1, 24),
		nil
	},
	walk = {
		8 = animation.create(load.bitmap("game/costumes/santino/walk8.png"), 24, 1, 24),
		2 = animation.create(load.bitmap("game/costumes/santino/walk2.png"), 24, 1, 24),
		4 = animation.create(load.bitmap("game/costumes/santino/walk4.png"), 24, 1, 24),
		6 = animation.create(load.bitmap("game/costumes/santino/walk6.png"), 24, 1, 24),
		nil
	},
	nil
}
costumes.santino = cost

