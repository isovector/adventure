--disable_input: this should be ALL lua; remove the c primitives
--engine.action: port the action_state object from C, obj -> object
----walkspot -> spot
--make actor.size
--engine.tooltip -> c's object_name

function engine.interface()
    local elapsed = 1 / framerate
    engine.life = engine.life + elapsed

    if not engine.allow_input then return end
    
    local action = engine.action
    local item = engine.item
    local mouse = engine.mouse
    
    mouse.cursor = 0
    engine.hovertext = ""
    
    if engine.action and engine.action.active then
        for htype, hitbox in pairs(action.hitboxes) do
            if hitbox.contains(mouse.pos) then
                mouse.cursor = 5
                action.method = htype
                engine.hovertext = htype .. " " .. action.name
            end
        end
                    
        if not mouse.buttons.left then
            if action.spot then
                player.walk(action.spot)
            end
        
            append_dispatch(player, action.type, action.object, action.method, action.flip)
        
            engine.action = nil
        end
    else
        local found = false
        for _, actor in ipairs(room.scene) do
            if actor.pos and not actor.ignore_ui then -- flush out foreground elements
                local hitbox = rect.create(actor.pos - actor.origin, actor.size)
                if hitbox.contains(mouse.pos) then
                    --[[or pixel perfect]]
                    found = 1
                    mouse.cursor = 5
                    engine.hovertext = actor.name
                    
                    if mouse.is_click("left") then
                        if item then
                            engine.callback(item.type, item.object, item.method)
                            engine.item = nil
                        else
                            engine.action = {
                                active = false,
                                flip = false,
                                type = "object",
                                object = actor.id,
                                name = actor.name,
                                pos = mouse.pos - (engine.actionbar.size * 0.5),
                                spot = make_walkspot(actor),
                                activates_at = engine.life + 0.5
                            }
                        end
                    end
                end
            end
        end
        
        if not found then
            for _, hotspot in pairs(room.hotspots) do
                if hotspot.contains(mouse.pos) then
                    engine.tooltip = hotspot.name
                    mouse.cursor = hotspot.cursor
                    found = true
                    engine.hovertext = hotspot.name
                    
                    if mouse.is_click("left") then
                        if item then
                            player.walk(hotspot.spot)
                            engine.callback(item.type, item.object, item.method)
                            engine.item = nil
                        else -- something about doors?
                            engine.action = {
                                active = false,
                                flip = false,
                                type = "hotspot",
                                object = hotspot.id,
                                name = hotspot.name,
                                pos = mouse.pos - (engine.actionbar.size * 0.5),
                                spot = hotspot.spot,
                                activates_at = engine.life + 0.5
                            }
                        end
                    end
                end
            end
        end
        
        if not found and mouse.is_click("left") then
            if room.is_walkable(mouse.pos) then
                player.walk(mouse.pos)
            end
            
            engine.action = nil
        end
    end
    
    if mouse.buttons.left and engine.action and not engine.action.active then
        if engine.life >= engine.action.activates_at then
            action.last_state = "game"
            engine.state = "action"
            action.active = true
            
            action.hitboxes = {
                talk = rect.create(action.pos.x, action.pos.y, 48, 48),
                look = rect.create(action.pos.x + 48, action.pos.y, 48, 48),
                touch = rect.create(action.pos.x + 96, action.pos.y, 48, 48)
            }                
        end
    elseif mouse.is_click("right") then
        engine.action = nil
        
        if item then
            engine.item = nil
        else
            engine.state = "inventory"
        end
    end
    
    for button, value in pairs(mouse.buttons) do
        if type(mouse.buttons["last_" .. button]) ~= "nil"  then
            mouse.buttons["last_" .. button] = mouse.buttons[button]
        end
    end
end