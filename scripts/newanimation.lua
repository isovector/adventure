animation = {
    cache = { },
    playing = { }
}

function animation.start(actor, name)
    local specific = actor .. "." .. name
    local anim = nil
    
    if cache[specific] then
        anim = cache[specific]
    elseif cache[name] then
        anim = cache[name]
    else
        return nil
    end
    
    table.insert(animation.playing, rig.animate(actor.skeleton, anim))
end

function animation.update(elapsed)
    for i, anim in ipairs(animation.playing) do
        coroutine.resume(anim, elapsed)
        
        if coroutine.status(anim) == "dead" then
            table.remove(animation.playing, i)
        end
    end
end