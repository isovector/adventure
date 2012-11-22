return function(room)
	local hotspot
	hotspot = Hotspot.new("sun", 5, "Sun", true, Polygon.new({
		135, 372,
		252, 257,
		400, 227,
		521, 247,
		624, 312,
		657, 353,
		488, 356,
		443, 450,
		418, 656,
		371, 499,
		318, 365,
	}))
	room:addHotspot(hotspot)
	hotspot = Hotspot.new("meadowdoor", 2, "Meadow", true, Polygon.new({
		684, 671,
		1242, 665,
		1237, 713,
		694, 715,
	}))
	hotspot:link("meadow", 717, 390)
	hotspot:setWalkspot(956, 657)
	room:addHotspot(hotspot)
	hotspot = Hotspot.new("crevice", 5, "Crevice", true, Polygon.new({
		494, 356,
		690, 474,
		664, 690,
		35, 688,
		32, 449,
		315, 375,
		417, 682,
		454, 476,
		452, 451,
	}))
	room:addHotspot(hotspot)
end
