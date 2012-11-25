return function(room)
    local hotspot
    hotspot = Hotspot.new("piano", 5, "Piano", true,
        Polygon.new({
            789, 467,
            814, 431,
            842, 432,
            856, 410,
            923, 418,
            918, 432,
            1080, 435,
            1082, 481,
            1058, 476,
            1058, 524,
            1039, 523,
            1038, 484,
            1014, 475,
            944, 467,
            944, 513,
            926, 519,
            927, 477,
            907, 470,
            893, 477,
            897, 522,
            874, 522,
            875, 487,
            868, 479,
            844, 477,
            844, 501,
            824, 524,
            806, 510,
            778, 506,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("menu", 8, "Menu", true,
        Polygon.new({
            39, 216,
            341, 221,
            376, 503,
            217, 508,
            39, 517,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("dining_door", 8, "Dining Room", true,
        Polygon.new({
            662, 503,
            673, 303,
            792, 300,
            793, 504,
        })    , 0)
    hotspot:link("outside", 1106, 591)
    hotspot:setWalkspot(717, 536)
    room:addHotspot(hotspot)
end
