color = { 
    black = 0x000000,
    red =   0xFF0000,
    white = 0xFFFFFF,
    transparent = -1
}

function color.make(r, g, b)
    r = math.clamp(r, 0, 255)
    g = math.clamp(g, 0, 255)
    b = math.clamp(b, 0, 255)
    
    return r * 0x10000 + g * 0x100 + b
end

--[[
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

function drawing.get_mode()
    return drawing.mode or "solid"
end

function drawing.set_mode(mode)
    drawing.mode = mode

    if mode == "solid" then
        drawing.raw_set_mode(0)
    elseif mode == "xor" then
        drawing.raw_set_mode(1)
    elseif mode == "trans" then
        drawing.raw_set_mode(5)
    end
end
    
function drawing.blit(bmp, pos, flipped, src, size)
    if flipped == nil then
        flipped = false
    end

    if src == nil then
        src = vector(0)
    end

    if size == nil then
        size = bmp.size
    end

    drawing.raw_blit(bmp, pos.x, pos.y, flipped, src.x, src.y, size.x, size.y)
end]]
