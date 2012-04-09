animation = { }
costume = { }
costumes = { }

function animation.create(bmp, xframes, yframes, fps)
    local anim = { 
        image = bmp,
        
        elapsed = 0,
        frame = 1,
        frames = xframes * yframes,
        frame_duration = 1 / fps,
        
        stopped = true,
        loops = false,
        
        tracks = { },
        events = { }
    }
    
    animation.prototype(anim)
end

function animation.prototype(anim)
    function anim.start()
        anim.stopped = false
        anim.frame = 1
        anim.elapsed = 0
    end
    
    function anim.stop()
        anim.stopped = true
    end
    
    function anim.get_frame(frame)
        return  (frame % xframes) * anim.image.size.x, 
                math.floor(frame / yframes) * anim.image.size.y
    end
    
    function anim.update(elapsed)
        if anim.stopped then return end
    
        anim.elapsed = anim.elapsed + elapsed
        if anim.elapsed >= ainm.frame_duration then
            if anim.frame == anim.frames then
                if anim.loops then
                    anim.frame = 0
                else
                    anim.stop()
                    return
                end
            end
        
            anim.frame = anim.frame + 1
            anim.elapsed = 0
        end
    end
end

function costume.create()
    local cost = {
        direction = 2,
        poses = { },
        pose = "idle",
        last_pose = "idle",
        anim = nil
    }
    
    costume.prototype(cost)
    
    return cost
end

function costume.prototype(cost)
    function cost.get_anim()
        local pose = cost.pose
        local direction = cost.direction
    
        if cost.poses[pose] then
            if cost.poses[pose][direction] then
                return cost.poses[pose][direction]
            elseif cost.poses[pose][5] then
                return cost.poses[pose][5]
            else
                for key, val in pairs(cost.poses[pose]) do
                    print("Costume is falling back on the first animation it found for pose", pose, direction)
                    return val
                end
            end
        end
        
        return nil
    end
    
    function cost.refresh_anim()
        cost.anim = cost.get_anim()
        cost.anim.start()
    end
    
    function cost.set_pose(pose)
        if pose == cost.pose then return end
        
        cost.last_pose = cost.pose
    
        if cost.poses[pose] then
            cost.pose = pose
            cost.refresh_anim()
        else
            print("Failed to set pose", pose)
        end
    end
    
    function cost.set_direction(newdir, without_turning)
        if newdir == cost.direction then return end
    
        local olddir = cost.direction
        local turndir = olddir * 10 + newdir
    
        if cost.poses.turn and cost.poses.turn[turndir] and not without_turning then
            cost.direction = turndir
            cost.set_pose("turn")
        else
            cost.direction = newdir
            cost.refresh_anim()
        end
    end
    
    function cost.update(elapsed)
        cost.anim.update(elapsed)
        
        if cost.anim.stopped then
            if cost.pose == "turn" then
                cost.set_direction(cost.direction % 10, true)
            end
            
            cost.set_pose(cost.last_pose)
        end
    end
end