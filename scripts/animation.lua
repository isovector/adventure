animation = {}
animations = {}

function animation.build_set(image, xcount, ycount, xorigin, yorigin)
    local set = {image = image, xcount = xcount, ycount = ycount}
    local width, height = get_image_size(image)
    set.width = width / xcount
    set.height = height / ycount
    set.xorigin = set.width / 2
    set.yorigin = set.height - 1
    set.anims = {}

    if yorigin then
        set.xorigin = xorigin
        set.yorigin = yorigin
    end

    return set
end

function animation.get_frame(set, frame)
    local x = frame % set.xcount
    local y = math.floor(frame / set.xcount)
    return x * set.width, y * set.height
end

function animation.start(set, anim)
    return {
        set = set,
        anim_name = anim,
        anim = set.anims[anim],
        time = 0,
        frame = set.anims[anim][1].frame,
        keyframe = 1
    }
end

function animation.switch(aplay, anim)
    if aplay.anim_name ~= anim then
        aplay.anim_name = anim
        aplay.anim = aplay.set.anims[anim]
        aplay.time = 0
        aplay.keyframe = 1
        aplay.frame = aplay.anim[1].frame
    end
end

function animation.play(aplay, elapsed)
    aplay.time = aplay.time + elapsed
    if aplay.time > aplay.anim[aplay.keyframe].duration then
        aplay.time = 0

        if table.getn(aplay.anim) == aplay.keyframe then
            aplay.keyframe = 1
        else
            aplay.keyframe = aplay.keyframe + 1
        end


        aplay.frame = aplay.anim[aplay.keyframe].frame
        if aplay.anim[aplay.keyframe].action then aplay.anim[aplay.keyframe].action(aplay) end
    end
end