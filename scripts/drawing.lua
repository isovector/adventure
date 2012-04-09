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
