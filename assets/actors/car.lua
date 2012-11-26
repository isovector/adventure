require "classes/actor"

costumes.car:addHotspot("idle", 5, Hotspot.new("hood", 5, "Hood", true,
    Polygon.new({
        0, 0,
        100, 0,
        100, 58,
        0, 58
    }), 0))
costumes.car:addHotspot("open", 5, Hotspot.new("hood", 5, "Hood", true,
    Polygon.new({
        0, 0,
        100, 0,
        100, 58,
        0, 58
    }), 0))
costumes.car:addHotspot("open", 5, Hotspot.new("sparkles", 5, "Sparkles", true,
    Polygon.new({
        0, 41,
        100, 41,
        100, 58,
        0, 58
    }), 5))

local actor = Actor.new("car", "Car", costumes.car, { 1, 0.7, 0 })
