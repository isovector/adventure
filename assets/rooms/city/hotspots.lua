return function(room)
	local hotspot
	hotspot = Hotspot.new("new1", 5, "New Hotspot 1", true, Polygon.new({
	}))
	room:addHotspot(hotspot)
	hotspot = Hotspot.new("udoor", 8, "Meadow", true, Polygon.new({
		515, 418,
		628, 420,
		668, 396,
		484, 372,
		496, 408,
	}))
	hotspot:link("meadow", 50, 621)
	hotspot:setWalkspot(569, 444)
	room:addHotspot(hotspot)
	hotspot = Hotspot.new("alleydoor", 2, "Alleyway", true, Polygon.new({
		887, 517,
		860, 452,
		1006, 466,
		1001, 525,
	}))
	hotspot:link("outside", 622, 255)
	hotspot:setWalkspot(935, 525)
	room:addHotspot(hotspot)
end
