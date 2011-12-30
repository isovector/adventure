load_script("scripts/rig.lua")
load_script("scripts/tasks.lua")
load_script("scripts/drawing.lua")
load_script("scripts/filesystem.lua")
load_script("scripts/repl.lua")

load_script("game/actors/richard/rig.lua")

index = 1

local last_msg = ""
local moving = false
local pos = vec(screen_width, screen_height) * 0.5

local keys = table.keys(root.bones)
engine.mouse.cursor = 10

events.game.tick.sub(function()
    local bone = root.bones[keys[index]]
    
    if engine.keys.is_press("n") then
        index = index % #keys + 1
        last_msg = "Switched to bone " .. keys[index]
    elseif engine.keys.is_press("b") then
        index = index % (#keys + 1) - 1
        
        if index <= 0 then
            index = #keys
        end
        
        last_msg = "Switched to bone " .. keys[index]
    end
    
    if engine.mouse.is_click("left") then
        moving = not moving
        
        if not moving then
            last_msg = "Switched moving off"
        else
            last_msg = "Switched moving on"
        end
    end
    
    if engine.keys.left then
        bone.default.rotation = bone.default.rotation - 1
        last_msg = "Rotated " .. keys[index] .. " ccw"
    elseif engine.keys.right then
        bone.default.rotation = bone.default.rotation + 1
        last_msg = "Rotated " .. keys[index] .. " cw"
    end
    
    if engine.keys.is_press("up") then
        bone.zorder = bone.zorder + 1
        last_msg = "Changed z-order of " .. keys[index] .. " to " .. bone.zorder
    elseif engine.keys.is_press("down") then
        bone.zorder = bone.zorder - 1
        last_msg = "Changed z-order of " .. keys[index] .. " to " .. bone.zorder
    end
    
    if moving and keys[index] ~= "root" then 
        bone.default.pos = rotate(engine.mouse.pos - pos - bone.parent.get_position(), -bone.parent.get_rotation())
        last_msg = "Moved " .. keys[index]
    end

    engine.mouse.pump()
    engine.keys.pump()
end)

engine.events.draw.sub(function()
    drawing.clear(color.make(255, 255, 0))
    
    bone = root.bones[keys[index]]

    drawing.text(vec(30), color.black, last_msg)
    drawing.blit(bone.image, vec(30, 40))
    
    drawing.skeleton(root, pos)
    
    drawing.blit(engine.resources.cursors, engine.mouse.pos - engine.cursors.offsets[engine.mouse.cursor + 1], false, vec(32 * engine.mouse.cursor, 0), vec(32))
end)