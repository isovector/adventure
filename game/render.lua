engine.events.draw.sub(function()
    if room and room.artwork then
        drawing.blit(room.artwork, [0, 0])
        
        for _, actor in ipairs(room.scene) do
            if actor.costume then
                local anim = actor.costume.anim
                drawing.blit(anim.image, actor.pos - actor.origin, false, vector(anim:get_frame(anim.frame)), anim.size)
            end
        end
    else
        drawing.clear(color.black)
        drawing.text([32, 32], color.make(255, 200, 0), -1, "Room failed to load")
        drawing.text([32, 46], color.make(255, 200, 0), -1, "This is generally indicative of a big lua problem")
    end
    
    if engine.state == "inventory" then
        drawing.blit(game.resources.inventory, [270, 210])
        
        local i = 0
        for _, item in pairs(player.inventory) do
            drawing.blit(item.image, [270 + 75 * (i % 10), 215 + 75 * math.floor(i / 10)])
            i = i + 1
        end
    end
    
    if engine.action and engine.action.active then
        drawing.blit(game.resources.action_bar, engine.action.pos)
    end
    
    if engine.item then
        drawing.blit(engine.item.image, input.mouse.pos)
    end
    
    drawing.blit(game.resources.cursors, input.mouse.pos - game.cursors.offsets[input.mouse.cursor + 1], false, [32 * input.mouse.cursor, 0], [32, 32])
    
    for _, msg in ipairs(conversation.words) do
        if not msg.aligned then
            drawing.text_center(msg.pos, msg.color, msg.outline, msg.message)
        else
            drawing.text(msg.pos, msg.color, msg.outline, msg.message)
        end
    end

    local i = 0
    local top = table.getn(conversation.options)
    for _, str in ipairs(conversation.options) do
        local col = color.white
        local y =  695 - 14 * (top - i)
    
        if rect([0, y], [1280, 14]).contains(input.mouse.pos) then
            col = color.make(255, 0, 0)
        end
        
        drawing.text([25, y], col, -1, str)
        i = i + 1
    end
    
    drawing.text([32, 32], color.make(255, 255, 255), -1, game.hovertext)
    drawing.text([screen_width - 50, 32], color.make(255, 0, 0), color.black, engine.fps)
end)