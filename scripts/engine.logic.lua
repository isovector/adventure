function engine.update()
    if engine.state == "game" then
        engine.game_state()
    elseif engine.state == "inventory" then
        engine.inventory_state()
    end
    
    engine.mouse.pump()
end

function engine.game_state()
    local elapsed = 1 / framerate
    engine.life = engine.life + elapsed

    if not engine.allow_input then return end
    
    local action = engine.action
    local item = engine.item
    local mouse = engine.mouse
    
    mouse.cursor = 0
    engine.hovertext = ""
    
    if engine.action and engine.action.active then
        action.method = ""
        for htype, hitbox in pairs(action.hitboxes) do
            if hitbox.contains(mouse.pos) then
                mouse.cursor = 5
                action.method = htype
                engine.hovertext = engine.verbs[htype].use:format(action.name)
            end
        end
                    
        if not mouse.buttons.left then
            if action.method ~= "" then
                if action.spot then
                    player.walk(action.spot)
                end
            
                append_dispatch(player, action.type, action.object, action.method, action.flip)
            end
        
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
                            engine.set_action("object", actor.id, actor.name, make_walkspot(actor))
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
                            engine.set_action("hotspot", hotspot.id, hotspot.name, hotspot.spot)
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
            --engine.state = "action"
            action.active = true
            
            action.hitboxes = { }
            
            for verb, data in pairs(engine.verbs) do
                action.hitboxes[verb] = rect.create(action.pos + data.offset, data.size)
            end
        end
    elseif mouse.is_click("right") then
        engine.action = nil
        
        if item then
            engine.item = nil
        else
            engine.state = "inventory"
        end
    end
end

function engine.inventory_state()
    local mouse = engine.mouse
    mouse.cursor = 0

    local i = 0
    for key, item in pairs(player.inventory) do
        if rect.create(vec(270 + 75 * (i % 10), 215 + 75 * math.floor(i / 10)), vec(64)).contains(mouse.pos) then
            engine.hovertext = item.name
            mouse.cursor = 5
            
            if mouse.is_click("left") then
                if engine.item then
                    print("combine")
                else
                    engine.set_action("item", key, item,name)
                end
            elseif mouse.is_upclick("left") and not engine.action.active then
                print("set item")
                engine.item = item
            end
        end

        i = i + 1
    end

    if engine.mouse.is_click("left") then
        if not rect.create(vec(270, 210), engine.resources.inventory.size).contains(mouse.pos) then
            engine.state = "game"
        end
    end
    
    if engine.mouse.is_click("right") then
        if engine.item then
            engine.item = nil
        else
            engine.state = "game"
        end
    end
end