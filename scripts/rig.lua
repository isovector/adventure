rig = { }

function rig.skeleton(bmp, origin, off, rotation, root)
    if not off then
        off = vec(0)
    end

    if not rotation then
        rotation = 0
    end
    
    local skel = {
        id = "root",
        
        parent = nil,
        children = { },
        
        image = bmp,
        image_offset = origin,
        zorder = 1,
        
        pos = vec(0),
        rotation = 0,
        
        default = {
            pos = off,
            rotation = rotation
        }
    }

    if not root then
        root = skel
        
        skel.bones = { root = skel }
    end

    function skel.bone(id, bmp, origin, off, rotation)
        local bone = rig.skeleton(bmp, origin, off, rotation, root)
        
        bone.id = id
        bone.parent = skel
        root.bones[id] = bone
        
        table.insert(skel.children, bone)
        
        return bone
    end
    
    function skel.get_rotation()
        if not skel.parent then
            return skel.default.rotation + skel.rotation 
        end

        return skel.parent.get_rotation() + skel.default.rotation + skel.rotation
    end
    
    function skel.get_position()
        if not skel.parent then
            return skel.default.pos + skel.pos
        end
        
        return skel.parent.get_position() + rotate(skel.default.pos + skel.pos, skel.parent.get_rotation())
    end

    return skel
end

function rig.trans(bone, off, rot)
    return {
        bone = bone,
        offset = off,
        rotation = rot
    }
end

function rig.keyframe(time, ...)
    return {
        time = time,
        transformations = {
            ...
        }
    }
end

function rig.splice(...)
    local args = { ... }
    local anim = {
        duration = 0
    }
    
    for _, frame in ipairs(args) do
        for _, transform in ipairs(frame.transformations) do
            if not anim[transform.bone] then
                anim[transform.bone] = {
                    x = interp(-999),
                    y = interp(-999),
                    rotation = interp(-999)
                }
            end
            
            anim[transform.bone].x[frame.time] = transform.offset.x
            anim[transform.bone].y[frame.time] = transform.offset.y
            anim[transform.bone].rotation[frame.time] = transform.rotation
            
            if frame.time > anim.duration then
                anim.duration = frame.time
            end
        end
    end
    
    return anim
end

function rig.animate(skel, anim)
    for bone, tab in pairs(anim) do
        if type(tab) == "table" then
            anim[bone].x[0] = 0
            anim[bone].y[0] = 0
            anim[bone].rotation[0] = 0
        end
    end
    
    return coroutine.create(function(time)
        while time < anim.duration do
            for bone, tab in pairs(anim) do
                if type(tab) == "table" and skel.bones[bone] then
                    if tab.x[time] ~= tab.x.error_value then
                        skel.bones[bone].pos.x = tab.x[time]
                    end
                  
                    if tab.y[time] ~= tab.y.error_value then
                        skel.bones[bone].pos.y = tab.y[time]
                    end
                    
                    if tab.rotation[time] ~= tab.rotation.error_value then
                        skel.bones[bone].rotation = tab.rotation[time]
                    end
                end
            end
            
            time = time + coroutine.yield()
        end
    end)
end

function rig.do_zorder(tab, bone)
    if not tab[bone.zorder] then
        tab[bone.zorder] = { }
    end
    
    table.insert(tab[bone.zorder], bone)
end

function rig.get_bone_table(bone, tab)
    if not tab then
        tab = { }
    end
    
    rig.do_zorder(tab, bone)
    
    for _, child in ipairs(bone.children) do
        rig.get_bone_table(child, tab)
    end
    
    return tab
end