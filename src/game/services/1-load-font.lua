local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'

font = MOAIFont.new()
--font:load('game/static/Casper.ttf')
font:load('game/static/arial-rounded.TTF')
font:preloadGlyphs(charcodes, 8)
font:preloadGlyphs(charcodes, 12)
font:preloadGlyphs(charcodes, 14)
font:preloadGlyphs(charcodes, 16)
font:preloadGlyphs(charcodes, 24)
font:preloadGlyphs(charcodes, 32)
font:preloadGlyphs(charcodes, 42)
font:preloadGlyphs(charcodes, 56)
font:preloadGlyphs(charcodes, 64)
font:preloadGlyphs(charcodes, 72)
font:preloadGlyphs(charcodes, 76)

--[[local image = MOAIImage.new()
image:load('game/static/casper.png', 0)

font:setCache()
font:setReader()
font:setImage(image)]]
