engine.events.draw.sub(function()
    if room and room.artwork then
        drawing.blit(room.artwork, vec(0))
        
        for _, actor in ipairs(room.scene) do
            if actor.aplay then
                local set = actor.aplay.set
                drawing.blit(set.image, actor.pos - actor.origin, actor.flipped, vec(animation.get_frame(set, actor.aplay.frame)), actor.size)
                
                local c = 0xFFFF00
                
                if in_ellipse(actor.pos, actor.pathsize, engine.mouse.pos) then
                    c = 0xFF0000
                end
                
                drawing.ellipse(actor.pos, actor.pathsize, c)
            elseif actor.sprite then
                drawing.blit(actor.sprite, actor.pos, actor.flipped)
            end
        end
    else
        drawing.clear(color.black)
        drawing.text(vec(32, 32), color.make(255, 200, 0), "Room failed to load")
        drawing.text(vec(32, 46), color.make(255, 200, 0), "This is generally indicative of a big lua problem")
    end
    
    if engine.state == "inventory" then
        drawing.blit(engine.resources.inventory, vec(270, 210))
        
        local i = 0
        for _, item in pairs(player.inventory) do
            drawing.blit(item.image, vec(270 + 75 * (i % 10), 215 + 75 * math.floor(i / 10)))
            i = i + 1
        end
    end
    
    if engine.action and engine.action.active then
        drawing.blit(engine.resources.action_bar, engine.action.pos)
    end
    
    if engine.item then
        drawing.blit(engine.item.image, engine.mouse.pos)
    end
    
    drawing.blit(engine.resources.cursors, engine.mouse.pos - engine.cursors.offsets[engine.mouse.cursor + 1], false, vec(32 * engine.mouse.cursor, 0), vec(32))
    
    for _, msg in ipairs(conversation.words) do
        drawing.blit(msg.message, msg.pos - vec(msg.message.size.x / 2, 0))
    end

    local i = 0
    local top = table.getn(conversation.options)
    for _, str in ipairs(conversation.options) do
        local col = color.white
        local y =  695 - 14 * (top - i)
    
        if rect.create(vec(0, y), vec(1280, 14)).contains(engine.mouse.pos) then
            col = color.make(255, 0, 0)
        end
        
        drawing.text(vec(25, y), col, str)
        i = i + 1
    end
    
    drawing.text(vec(32), color.make(255, 255, 255), engine.hovertext)
    drawing.text(vec(screen_width - 50, 32), color.make(255, 0, 0), color.black, engine.fps)
end)