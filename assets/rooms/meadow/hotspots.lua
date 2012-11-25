return function(room)
    local hotspot
    hotspot = Hotspot.new("sun", 5, "Sun", true,
        Polygon.new({
            33, 326,
            30, 217,
            127, 217,
            201, 253,
            239, 300,
            262, 356,
        })    , 0)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("ledge", 4, "Leave", true,
        Polygon.new({
            7, 325,
            58, 330,
            74, 699,
            5, 717,
        })    , 0)
    hotspot:link("city", 575, 446)
    hotspot:setWalkspot(87, 517)
    room:addHotspot(hotspot)
    hotspot = Hotspot.new("horizondoor", 8, "Horizon", true,
        Polygon.new({
            449, 335,
            448, 389,
            847, 387,
            895, 352,
        })    , 0)
    hotspot:link("desert", 802, 672)
    hotspot:setWalkspot(642, 404)
    room:addHotspot(hotspot)
end
