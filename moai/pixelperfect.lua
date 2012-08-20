newclass("PixelPerfect", 
    function(path)
        local img = MOAIImageTexture.new()
        img:load(path, MOAIImage.TRUECOLOR + MOAIImage.PREMULTIPLY_ALPHA)
        
        return { texture = img }
    end
)

function PixelPerfect:apply(prop)
    local quad = MOAIGfxQuad2D.new()
    
    quad:setTexture(self.texture)
    prop:setDeck(quad)
    prop.pixelPerfect = self
    
    return quad
end

function PixelPerfect:check(prop, x, y)
    local rx, ry = prop:getRect()
    local lx, ly = prop:getLoc()
    
    local x0 = rx + lx
    local y0 = ry + ly
    
    -- get local space coords
    x = x - x0
    y = y - y0
    
    local _, _, _, a = self.texture:getRGBA(x, y)
    return a ~= 0
end
