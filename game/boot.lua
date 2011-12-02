rooms["outside"].switch()
player = actors.gomez

engine.add_verb("talk", "Talk to %s", vec(0), vec(48))
engine.add_verb("look", "Look at %s", vec(48, 0), vec(48))
engine.add_verb("touch", "Touch %s", vec(96, 0), vec(48))

clock.set_speed(25, 60)

player.events.tick.sub(function(elapsed)
    local xoffset = math.clamp(player.pos.x - screen_width / 2, 0, room_width - screen_width)
    local yoffset = math.clamp(player.pos.y - screen_height / 2, 0, room_height - screen_height)
    
    --set_viewport(xoffset, yoffset)
end)

give_item(player, "beer")