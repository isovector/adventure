return function(room)
	room:addHotspot(Hotspot.new("window", 5, "Window", Polygon.new({
		765, 156,
		765, 50,
		866, 62,
		854, 219,
	})))
	room:addHotspot(Hotspot.new("door", 8, "Door", Polygon.new({
		1017, 566,
		1016, 461,
		1033, 394,
		1089, 371,
		1137, 379,
		1181, 407,
		1207, 447,
		1207, 569,
	})))
end
