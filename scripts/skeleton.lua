function skeleton(bmp, origin, off, rotation, counter)
    if not off then
        off = vec(0)
    end

    if not rotation then
        rotation = 0
    end
    
    local skel = {
        id = 1,
        
        parent = nil,
        children = { },
        
        image = bmp,
        image_offset = origin,
        zorder = 1,
        
        pos = off,
        rotation = rotation
    }

    if not counter then
        counter = {
            id = 1,
            
            get_id = function()
                counter.id = counter.id + 1
                return counter.id
            end
        }
    end

    function skel.bone(bmp, origin, off, rotation)
        local bone = skeleton(bmp, origin, off, rotation, counter)
        
        bone.parent = skel
        bone.id = counter.get_id()
        
        table.insert(skel.children, bone)
        
        return bone
    end
    
    function skel.get_rotation()
        if not skel.parent then
            return skel.rotation
        end

        return skel.parent.get_rotation() + skel.rotation
    end
    
    function skel.get_position()
        if not skel.parent then
            return skel.pos
        end
        
        return skel.parent.get_position() + rotate(skel.pos, skel.parent.get_rotation())
    end

    return skel
end

--[[
function do_zorder(tab, bone)
    if not tab[bone.zorder] then
        tab[bone.zorder] = { }
    end
    
    table.insert(tab[bone.zorder], bone)
end

function draw_bone(bone, tab)
    if not tab then
        tab = { }
    end
    
    do_zorder(tab, bone)
    
    for _, child in ipairs(bone.children) do
        draw_bone(child, tab)
    end
    
    return tab
end

engine.events.draw.sub(function()
    drawing.clear(color.black)
    body.pos = engine.mouse.pos
    calve.rotation = calve.rotation + 1
    calve2.rotation = calve2.rotation - 1
    
    local tab = draw_bone(body)
    
    local keys = table.keys(tab)
    
    for _, key in ipairs(keys) do
        for _, bone in pairs(tab[key]) do
            drawing.blit_rotate(bone.image, bone.get_position(), bone.image_offset, bone.get_rotation())
        end
    end
    ]]

--[[
body = skeleton(bitmap("resources/vampire/torso.pcx"), vec(49,67))
body.pos = vec(250)
body.zorder = 5

local leg = body.bone(bitmap("resources/vampire/head.pcx"), vec(19, 19), vec(2, -62))
leg.zorder = 6

leg = body.bone(bitmap("resources/vampire/left-thigh.pcx"), vec(10, 10), vec(-20, 10))
leg.zorder = 4
leg = leg.bone(bitmap("resources/vampire/left-calve.pcx"), vec(69, 11), vec(32, 32))
leg.zorder = 6
leg = leg.bone(bitmap("resources/vampire/left-foot.pcx"), vec(22, 8), vec(-35, 65))
leg.zorder = 5

leg = body.bone(bitmap("resources/vampire/left-thigh.pcx"), vec(10, 10), vec(9, 5))
leg.zorder = 2
leg = leg.bone(bitmap("resources/vampire/left-calve.pcx"), vec(69, 11), vec(32, 32))
leg.zorder = 4
leg = leg.bone(bitmap("resources/vampire/left-foot.pcx"), vec(22, 8), vec(-35, 65))
leg.zorder = 3]]