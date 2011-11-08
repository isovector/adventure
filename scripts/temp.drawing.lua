color = { new, transparent }

drawing = {
   
    clear = function(color)
        clear_to_color(c.screen, color)
    end,
    
    text = function(pos, color, background, format, ...)
        textout_ex(c.screen, c.font, string.format(format, ...), pos.x, pos.y, color, background)
    end
    
    text_center = function(pos, color, background, format, ...)
        textout_center_ex(c.screen, c.font, string.format(format, ...), pos.x, pos.y, color, background)
    end,
    
    blit = function(bitmap, pos, flipped, src, size)
        BITMAP *tmp = create_bitmap(size.x, size.y)
        blit(bitmap, tmp, src.x, src.y, 0, 0, size.x, size.y)
        
        draw_sprite_ex(c.screen, tmp, pos.x - xorigin - viewport.x, pos.y - yorigin - viewport.y, DRAW_SPRITE_NORMAL, flipped);
    end
}