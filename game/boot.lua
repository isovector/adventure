rooms["outside"].switch()
enable_path(17)
player = actors.gomez

player.events.tick.sub(function(elapsed)
    local xoffset = math.clamp(player.pos.x - screen_width / 2, 0, room_width - screen_width)
    local yoffset = math.clamp(player.pos.y - screen_height / 2, 0, room_height - screen_height)
    
    --set_viewport(xoffset, yoffset)
end)

clock.set_speed(25, 60)