load_script("scripts/rig.lua")
load_script("scripts/tasks.lua")
load_script("scripts/drawing.lua")
load_script("scripts/filesystem.lua")
--load_script("scripts/repl.lua")

load_script("game/actors/richard/rig.lua")

tonumber("5")

index = 1

last_msg = ""
moving = false
pos = vec(screen_width, screen_height) * 0.5
bone_offset = vec(30, 40)

kframes = { }
frame = 0

keys = table.keys(root.bones)
engine.mouse.cursor = 10

function get_skel_structure(bone)
    if #bone.children == 0 then
        return bone.id
    end
    
    
end

dofile("utils/choreo/logic.lua")
dofile("utils/choreo/render.lua")
