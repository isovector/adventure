return function(room)
	room:addHotspot(Hotspot.new("new1", 5, "New Hotspot", Polygon.new({
		765, 156,
		765, 50,
		866, 62,
		854, 219,
	})))
	room:addHotspot(Hotspot.new("new2", 5, "New Hotspot", Polygon.new({
		1012, 565,
		1011, 451,
		1045, 389,
		1125, 373,
		1161, 394,
		1203, 444,
		1207, 568,
	})))
end
