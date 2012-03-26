local draw = function()
    drawing.clear(color.make(255, 255, 0))
    
    if not input.keys.h then
        drawing.blit(image, vector(0))
    end
    
    local mode = drawing.get_mode()
    drawing.set_mode("trans")
    
    if vertices ~= waypoints then
        c = 0xFF8800
        if vertices == navigation then
            c = 0x00FF00
        else
            c = colors[curhotspot]
        end

        drawing.polygon(vertices, 0x7F000000 + c)
        
        for _, vertex in ipairs(vertices) do
            drawing.text(vertex, 0x00FF00, vertex.n)
        end
    else
        for _, waypoint in ipairs(vertices) do
            drawing.text(waypoint, 0x0000FF, "w")
        end
    end
    
    drawing.set_mode(mode)
    
    if input.keys.h then
        drawing.blit(hot, vector(0))
    end
    
    drawing.blit(game.resources.cursors, input.mouse.pos - game.cursors.offsets[input.mouse.cursor + 1], false, vector(32 * input.mouse.cursor, 0), vector(32))
end

engine.events.draw.sub(draw)
