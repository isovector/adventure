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