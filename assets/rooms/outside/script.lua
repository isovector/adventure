require "classes/polygon"


    local poly = Polygon.new(550, 406, 571, 404, 584, 420, 584, 439, 574, 454, 566, 454, 570, 476, 573, 514, 571, 540, 567, 572, 567, 598, 553, 599, 553, 562, 556, 535, 554, 517, 550, 488, 551, 454, 547, 452, 536, 438, 534, 415)

    local src = MOAIImageTexture.new()
    src:load(room.img_path, MOAIImage.TRUECOLOR + MOAIImage.PREMULTIPLY_ALPHA)
    
    local sx, sy, dx, dy = poly:getBox()
    local w, h = dx - sx, dy - sy
    
    local img = MOAIImageTexture.new()
    img:init(w, h)
    
    for y = 1, h do
        for x = 1, w do
            if poly:hitTest(x + sx, y + sy) then
                img:setRGBA(x, y, src:getRGBA(x + sx, y + sy))
            end
        end
    end
    
    --img:writePNG("stopsign.png")
    
    img:invalidate()
    
    local quad = MOAIGfxQuad2D.new()
    quad:setRect(0, -h, w, 0)
    quad:setUVRect(0, 0, 1, 1)
    quad:setTexture(img)

    local prop = MOAIProp2D.new()
    prop:setDeck(quad)
    
    prop:setLoc(sx, sy + h)
    prop:setPriority(sy + h)

    Sheet.getSheet("foreground"):insertProp(prop)
