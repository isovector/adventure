local r = "game/actors/richard/"
local arm = nil
local leg = nil
local t = nil

root = rig.skeleton(bitmap(r.."torso.pcx"), vec(36, 121))
root.zorder = 10

t = root.bone("head", bitmap(r.."head.pcx"), vec(52, 118), vec(0, -118))
t.zorder = 11

arm = root.bone("lbicep", bitmap(r.."left-bicep.pcx"), vec(8, 13), vec(28, -100), 45)
arm.zorder = 9
arm = arm.bone("lfore", bitmap(r.."left-forearm.pcx"), vec(10, 70), vec(54, 2), 70)
arm.zorder = 12

arm = root.bone("rbicep", bitmap(r.."right-bicep.pcx"), vec(66, 13), vec(-28, -100), -45)
arm.zorder = 9
arm = arm.bone("rfore", bitmap(r.."right-forearm.pcx"), vec(23, 70), vec(-54, 2), -70)
arm.zorder = 12

leg = root.bone("lthigh", bitmap(r.."left-thigh.pcx"), vec(7, 25), vec(5, -5), 32)
leg.zorder = 8
leg = leg.bone("lcalve", bitmap(r.."left-calve.pcx"), vec(30, 9), vec(35, 18), -45)
leg.zorder = 9
leg = leg.bone("lfoot", bitmap(r.."left-foot.pcx"), vec(14, 3), vec(-17, 35), 15)
leg.zorder = 10

leg = root.bone("rthigh", bitmap(r.."right-thigh.pcx"), vec(50, 25), vec(-5, -5), -32)
leg.zorder = 8
leg = leg.bone("rcalve", bitmap(r.."right-calve.pcx"), vec(14, 9), vec(-35, 18), 45)
leg.zorder = 9
leg = leg.bone("rfoot", bitmap(r.."right-foot.pcx"), vec(41, 3), vec(17, 35), -15)
leg.zorder = 10