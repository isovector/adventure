engine.events.draw.sub(function()
    if room and room.artwork then
        drawing.blit(room.artwork, vec(0), false, vec(0), room.artwork.size)
        
        for _, actor in ipairs(room.scene) do
            if actor.aplay then
                local set = actor.aplay.set
                drawing.blit(set.image, actor.pos - actor.origin, actor.flipped, vec(animation.get_frame(set, actor.aplay.frame)), actor.size)
            elseif actor.sprite then
                drawing.blit(actor.sprite, actor.pos, actor.flipped, vec(0), actor.sprite.size)
            end
        end
    else
        drawing.clear(color.black)
        drawing.text(vec(32, 32), color.make(255, 200, 0), color.transparent, "Room failed to load")
        drawing.text(vec(32, 46), color.make(255, 200, 0), color.transparent, "This is generally indicative of a big lua problem")
    end
    
    if engine.state == "inventory" then
        drawing.blit(engine.resources.inventory, vec(270, 210), false, vec(0), engine.resources.inventory.size)
        
        local i = 0
        for _, item in pairs(player.inventory) do
            drawing.blit(item.image, vec(270 + 75 * (i % 10), 215 + 75 * math.floor(i / 10)), false, vec(0), item.image.size)
            i = i + 1
        end
    end
    
    if engine.action and engine.action.active then
        drawing.blit(engine.resources.action_bar, engine.action.pos, false, vec(0), engine.resources.action_bar.size)
    end
    
    if engine.item then
        drawing.blit(engine.item.image, engine.mouse.pos, false, vec(0), engine.item.image.size)
    end
    
    drawing.blit(engine.resources.cursors, engine.mouse.pos - engine.cursors.offsets[engine.mouse.cursor + 1], false, vec(32 * engine.mouse.cursor, 0), vec(32))
    drawing.text(vec(32), color.make(255, 255, 255), color.transparent, engine.hovertext)
    drawing.text(vec(screen_width - 50, 32), color.make(255, 0, 0), color.transparent, engine.fps)
end)