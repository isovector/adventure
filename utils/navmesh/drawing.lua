local draw = function()
    drawing.clear(color.make(255, 255, 0))
    drawing.blit(image, vec(0))
    
    drawing.polygon(vertices, 0x7FFF8800)
    
    for _, vertex in ipairs(vertices) do
        drawing.text(vertex, 0x00FF00, vertex.n)
    end
    
    for _, triangle in ipairs(triangles) do
        drawing.polygon(triangle, 0x7FFF00FF)
    end
    
    for _, rect in ipairs(rects) do
        drawing.rect(rect, 0x7F000000)
    end
    
    drawing.blit(engine.resources.cursors, engine.mouse.pos - engine.cursors.offsets[engine.mouse.cursor + 1], false, vec(32 * engine.mouse.cursor, 0), vec(32))
end

engine.events.draw.sub(draw)
