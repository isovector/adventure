local last_value = ""

local console = function(input)
    last_value = input
end

local logic = function()
    local bone = root.bones[keys[index]]
    
    if input.keys.is_press("n") then
        index = index % #keys + 1
        last_msg = "Switched to bone " .. keys[index]
    elseif input.keys.is_press("b") then
        index = index % (#keys + 1) - 1
        
        if index <= 0 then
            index = #keys
        end
        
        last_msg = "Switched to bone " .. keys[index]
    end
    
    if input.keys.is_press("k") then
        open_console(false)
        
        -- TODO(sandy): ensure keyframe is numeric first!
        if true then
            last_msg = "new keyframe " .. last_value
            
            table.insert(kframes, last_value)
        else
            last_msg = "bad keyframe " .. last_value
        end
    end
    
    if input.mouse.is_click("left") then
        if rect(bone_offset, bone.image.size):Contains(input.mouse.pos) 
            and not moving then
            bone.image_offset = input.mouse.pos - bone_offset
        else
            moving = not moving
            
            if not moving then
                last_msg = "Switched moving off"
            else
                last_msg = "Switched moving on"
            end
        end
    end
    
    if input.keys.left then
        bone.default.rotation = bone.default.rotation - 1
        last_msg = "Rotated " .. keys[index] .. " ccw"
    elseif input.keys.right then
        bone.default.rotation = bone.default.rotation + 1
        last_msg = "Rotated " .. keys[index] .. " cw"
    end
    
    if input.keys.is_press("up") then
        bone.zorder = bone.zorder + 1
        last_msg = "Changed z-order of " .. keys[index] .. " to " .. bone.zorder
    elseif input.keys.is_press("down") then
        bone.zorder = bone.zorder - 1
        last_msg = "Changed z-order of " .. keys[index] .. " to " .. bone.zorder
    end
    
    if moving and keys[index] ~= "root" then 
        bone.default.pos = rotate(input.mouse.pos - pos - bone.parent.get_position(), -bone.parent.get_rotation())
        last_msg = "Moved " .. keys[index]
    end

    input.mouse.pump()
    input.keys.pump()
end

events.game.tick.sub(logic)
events.console.input.sub(console)