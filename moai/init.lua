SIZE = { x = 1280, y = 720 }

MOAISim.openWindow("Earnest Money", 1280, 720)

viewport = MOAIViewport.new()
viewport:setSize(1280, 720)
viewport:setScale(1280, -720)
viewport:setOffset(-1, 1)

dofile("bg.lua")
dofile("vis.lua")
