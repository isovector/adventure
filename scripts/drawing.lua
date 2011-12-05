color = { 
    black = 0,
    white = 0xFFFFFF,
    transparent = -1
}

function color.make(r, g, b)
    r = math.clamp(r, 0, 255)
    g = math.clamp(g, 0, 255)
    b = math.clamp(b, 0, 255)
    
    return r * 65536 + g * 256 + b
end

function drawing.text(pos, col, background, format, ...)
    if type(background) ~= "number" then
        drawing.text(pos, col, color.transparent, background, format, ...)
        return
    end

    drawing.raw_text(pos.x, pos.y, col, background, string.format(format, ...))
end

function drawing.text_center(pos, col, background, format, ...)
    if type(background) ~= "number" then
        drawing.text_center(pos, col, color.transparent, background, format, ...)
        return
    end

    drawing.raw_text_center(pos.x, pos.y, col, background, string.format(format, ...))
end
    
function drawing.blit(bmp, pos, flipped, src, size)
    if type(flipped) == "nil" then
        flipped = false
    end

    if src == nil then
        src = vec(0)
    end

    if size == nil then
        size = bmp.size
    end

    drawing.raw_blit(bmp, pos.x, pos.y, flipped, src.x, src.y, size.x, size.y)
end
