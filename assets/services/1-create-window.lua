mrequire "classes/vim"

MOAISim.openWindow("Earnest Money", 1280, 720)

viewport = MOAIViewport.new()
viewport:setSize(1280, 720)
viewport:setScale(1280, -720)
viewport:setOffset(-1, 1)

--------------------------------------------------

vim = Vim.new()
