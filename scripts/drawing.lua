color = { 
    black = 0,
    transparent = -1
}

function color.make(r, g, b)
    r = math.clamp(r, 0, 255)
    g = math.clamp(g, 0, 255)
    b = math.clamp(b, 0, 255)
    
    return r * 65536 + g * 256 + b
end

function drawing.text(pos, color, background, format, ...)
    drawing.raw_text(pos.x, pos.y, color, background, string.format(format, ...))
end

function drawing.text_center(pos, color, background, format, ...)
    drawing.raw_text_center(pos.x, pos.y, color, background, string.format(format, ...))
end
    
function drawing.blit(bmp, pos, flipped, src, size)
    drawing.raw_blit(bmp, pos.x, pos.y, flipped, src.x, src.y, size.x, size.y)
end