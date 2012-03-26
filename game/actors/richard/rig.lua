local r = "game/actors/richard/"
local arm = nil
local leg = nil
local t = nil

root = rig.skeleton(load.image(r.."torso.pcx"), vector(36, 121))
root.zorder = 10

t = root.bone("head", load.image(r.."head.pcx"), vector(52, 118), vector(0, -118))
t.zorder = 11

arm = root.bone("lbicep", load.image(r.."left-bicep.pcx"), vector(8, 13), vector(28, -100), 45)
arm.zorder = 9
arm = arm.bone("lfore", load.image(r.."left-forearm.pcx"), vector(10, 70), vector(54, 2), 70)
arm.zorder = 12

arm = root.bone("rbicep", load.image(r.."right-bicep.pcx"), vector(66, 13), vector(-28, -100), -45)
arm.zorder = 9
arm = arm.bone("rfore", load.image(r.."right-forearm.pcx"), vector(23, 70), vector(-54, 2), -70)
arm.zorder = 12

leg = root.bone("lthigh", load.image(r.."left-thigh.pcx"), vector(7, 25), vector(5, -5), 32)
leg.zorder = 8
leg = leg.bone("lcalve", load.image(r.."left-calve.pcx"), vector(30, 9), vector(35, 18), -45)
leg.zorder = 9
leg = leg.bone("lfoot", load.image(r.."left-foot.pcx"), vector(14, 3), vector(-17, 35), 15)
leg.zorder = 10

leg = root.bone("rthigh", load.image(r.."right-thigh.pcx"), vector(50, 25), vector(-5, -5), -32)
leg.zorder = 8
leg = leg.bone("rcalve", load.image(r.."right-calve.pcx"), vector(14, 9), vector(-35, 18), 45)
leg.zorder = 9
leg = leg.bone("rfoot", load.image(r.."right-foot.pcx"), vector(41, 3), vector(17, 35), -15)
leg.zorder = 10