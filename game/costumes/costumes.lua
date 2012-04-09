local cost = nil
cost = costume.create()
cost.poses = {
	idle = { },
	walk = { },
	nil
}
cost.poses.idle[5] = animation.create(load.image("game/costumes/santino/idle5.png"), 24, 1, 24)
cost.poses.idle[5].loops = true
cost.poses.walk[8] = animation.create(load.image("game/costumes/santino/walk8.png"), 24, 1, 24)
cost.poses.walk[8].loops = true
cost.poses.walk[2] = animation.create(load.image("game/costumes/santino/walk2.png"), 24, 1, 24)
cost.poses.walk[2].loops = true
cost.poses.walk[4] = animation.create(load.image("game/costumes/santino/walk4.png"), 24, 1, 24)
cost.poses.walk[4].loops = true
cost.poses.walk[6] = animation.create(load.image("game/costumes/santino/walk6.png"), 24, 1, 24)
cost.poses.walk[6].loops = true
costumes.santino = cost

