function engine.update()
    local elapsed = 1 / framerate
    
    game.life = game.life + elapsed

    if table.getn(conversation.options) ~= 0 then
        engine.dialogue_state()
    else
        engine.action_state()
        
        if engine.state == "game" then
            engine.game_state()
        elseif engine.state == "inventory" then
            engine.inventory_state()
        end
    end
    
    input.mouse.pump()
    input.keys.pump()
end

function engine.dialogue_state()
    if input.mouse.is_click("left") then
        local top = table.getn(conversation.options)
        local i = 0
        
        for _, str in ipairs(conversation.options) do
            local y =  695 - 14 * (top - i)
        
            if rect.create(vector(0, y), vector(1280, 14)).contains(input.mouse.pos) then
                conversation.continue(i + 1)
                return
            end
            
            i = i + 1
        end
    end
end

function engine.action_state()
    local action = engine.action
    local mouse = input.mouse
    mouse.cursor = 0
    
    if not action or not action.active then return end

    action.method = ""
    for htype, hitbox in pairs(action.hitboxes) do
        if hitbox.contains(mouse.pos) then
            mouse.cursor = 5
            action.method = htype
            game.hovertext = game.verbs[htype].use:format(action.name)
        end
    end
                
    if not mouse.buttons.left then
        if action.method ~= "" then
            if action.spot then
                player:walk(action.spot)
                game.append_dispatch(player, action.type, action.object, action.method, action.flip)
            else
                game.dispatch(action.type, action.object, action.method)
            end
            
            if action.last_state then
                engine.state = action.last_state
            end
        end
    
        engine.action = nil
    end
end

function engine.game_state()
    if not engine.allow_input then return end
    
    local action = engine.action
    local item = engine.item
    local mouse = input.mouse
    
    if engine.action and engine.action.active then return end
    
    mouse.cursor = 0
    game.hovertext = ""
    
    
    local found = false
    for _, actor in ipairs(room.scene) do
        if actor.origin and not actor.ignore_ui then -- flush out foreground elements
            local hitbox = rect.create(actor.pos - actor.origin, actor.size)
            if hitbox.contains(mouse.pos) then
                --[[or pixel perfect]]
                found = 1
                mouse.cursor = 5
                game.hovertext = actor.name
                
                if mouse.is_click("left") then
                    if item then
                        game.dispatch(item.type, item.object, item.method)
                        engine.item = nil
                    else
                        game.set_action("object", actor.id, actor.name, game.make_walkspot(actor))
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
                game.hovertext = hotspot.name
                
                if mouse.is_click("left") then
                    if hotspot.clickable then
                        if engine.item then
                            engine.item = nil
                        else
                            hotspot.events.click()
                        end
                    else
                        if item then
                            player:walk(hotspot.spot)
                            game.dispatch(item.type, item.object, item.method)
                            engine.item = nil
                        else
                            game.set_action("hotspot", hotspot.id, hotspot.name, hotspot.spot)
                        end
                    end
                end
            end
        end
    end
    
    if not found and mouse.is_click("left") then
        if engine.item then
            engine.item = nil
        elseif room:is_walkable(mouse.pos) then
            player:walk(mouse.pos)
        end
        
        engine.action = nil
    end
    
    if mouse.buttons.left and engine.action and not engine.action.active then
        if game.life >= engine.action.activates_at then
            action.last_state = "game"
            action.active = true
            
            action.hitboxes = { }
            for verb, data in pairs(game.verbs) do
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
    if engine.action and engine.action.active then return end

    local mouse = input.mouse
    local action = engine.action
    mouse.cursor = 0

    local i = 0
    for key, item in pairs(player.inventory) do
        if rect.create(vector(270 + 75 * (i % 10), 215 + 75 * math.floor(i / 10)), vector(64)).contains(mouse.pos) then
            game.hovertext = item.name
            mouse.cursor = 5
            
            if mouse.is_click("left") then
                if engine.item then
                    game.dispatch("combine", key, engine.item.id)
                    
                    engine.item = nil
                    engine.just_item = true
                else
                    game.set_action("item", key, item.name)
                end
            elseif mouse.is_upclick("left") and not (engine.action and engine.action.active) then
                if not engine.just_item then
                    engine.item = item
                end
                
                engine.just_item = nil
            end
        end

        i = i + 1
    end

    if input.mouse.is_click("left") and not game.inventory_rect.contains(mouse.pos) then
        engine.state = "game"
    end
    
    if mouse.buttons.left and engine.action and not engine.action.active then
        if game.life >= engine.action.activates_at then
            action.last_state = "game"
            action.active = true
            
            action.hitboxes = { }
            for verb, data in pairs(game.verbs) do
                action.hitboxes[verb] = rect.create(action.pos + data.offset, data.size)
            end
        end
    elseif input.mouse.is_click("right") then
        if engine.item then
            engine.item = nil
        else
            engine.state = "game"
        end
    else
        engine.action = nil
    end
end