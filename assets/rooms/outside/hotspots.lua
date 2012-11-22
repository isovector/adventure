return function(room)
	local hotspot
	hotspot = Hotspot.new("window", 5, "Window", true, Polygon.new({
		765, 156,
		765, 50,
		866, 62,
		854, 219,
	}))
	room:addHotspot(hotspot)
	hotspot = Hotspot.new("door", 8, "Door", true, Polygon.new({
		1017, 566,
		1016, 461,
		1033, 394,
		1089, 371,
		1137, 379,
		1181, 407,
		1207, 447,
		1207, 569,
	}))
	hotspot:link("inside", 728, 529)
	hotspot:setWalkspot(1107, 593)
	room:addHotspot(hotspot)
	hotspot = Hotspot.new("citydoor", 8, "City", true, Polygon.new({
		519, 241,
		514, 14,
		630, 10,
		722, 240,
	}))
	hotspot:link("city", 924, 541)
	hotspot:setWalkspot(601, 271)
	room:addHotspot(hotspot)
end
