return function(room)
    local hotspot
    hotspot = Hotspot.new("doorback", 2, "Back", true,
        Polygon.new({
            2, 615,
            1278, 610,
            1279, 718,
            0, 718,
        })    , 0)
    hotspot:setWalkspot(680, 595)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("wibbly", 5, "Blue Wibbly Bit", true,
        Polygon.new({
            613, 403,
            617, 209,
            665, 177,
            723, 176,
            752, 230,
            776, 422,
            742, 375,
            694, 361,
            646, 367,
            625, 377,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("tube", 5, "Tube", true,
        Polygon.new({
            300, 399,
            301, 426,
            339, 474,
            407, 457,
            488, 359,
            460, 317,
            380, 317,
            372, 360,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("wiring", 5, "Wiring", true,
        Polygon.new({
            788, 196,
            803, 340,
            857, 346,
            867, 183,
            914, 194,
            941, 153,
            940, 107,
            801, 99,
            813, 119,
            813, 143,
            788, 155,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("bluepipe", 5, "Blue Pipe", true,
        Polygon.new({
            1187, 290,
            1230, 331,
            1244, 412,
            1205, 485,
            1147, 531,
            1153, 536,
            1213, 498,
            1252, 436,
            1255, 355,
            1237, 312,
            1197, 282,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("greentube", 5, "Green Tube", true,
        Polygon.new({
            608, 437,
            872, 513,
            874, 496,
            616, 427,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("wiring2", 5, "Wiring", true,
        Polygon.new({
            187, 62,
            441, 76,
            527, 123,
            551, 173,
            467, 186,
            346, 189,
            267, 222,
            245, 203,
            242, 167,
            158, 154,
            137, 213,
            92, 231,
            87, 181,
            119, 108,
            170, 108,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("stand", 5, "Hood Stand", true,
        Polygon.new({
            23, 1,
            154, 546,
            166, 543,
            37, 3,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("belt", 5, "Belt", true,
        Polygon.new({
            425, 543,
            435, 563,
            692, 542,
            740, 579,
            754, 558,
            725, 520,
        })    , 0)
    room:addHotspot(hotspot)
end
