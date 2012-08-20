costumes = { }

newclass("Animation", 
    function(deck, curve)
        return {
            deck = deck,
            curve = curve,
            loops = false,
            anim = MOAIAnim.new()
        }
    end
)

function Animation:start(prop)
    prop:setDeck(self.deck)
    prop:setIndex(1)
    
    if self.anim then
        self.anim:detach()
    end
    
    local anim = MOAIAnim.new()
    anim:reserveLinks(1)
    anim:setLink(1, self.curve, prop, MOAIProp2D.ATTR_INDEX)
    
    anim:setMode(self.loops and MOAITimer.LOOP or MOAITimer.NORMAL)
    anim:start()
    
    self.anim = anim
end

function Animation:stop()
    self.anim:detach()
end

newclass("Costume",
    function()
        return {
            direction = 2,
            poses = { },
            pose = "idle",
            last_pose = "idle",
            anim = nil,
            prop = MOAIProp2D.new()
        }
    end
)

function Costume:bind(prop)
    self.prop = prop
end

function Costume:get_anim()
    local pose = self.pose
    local direction = self.direction

    if self.poses[pose] then
        if self.poses[pose][direction] then
            return self.poses[pose][direction]
        elseif self.poses[pose][5] then
            return self.poses[pose][5]
        else
            for key, val in pairs(self.poses[pose]) do
                print("Costume is falling back on the first animation it found for pose", pose, direction)
                return val
            end
        end
    end
    
    return nil
end

function Costume:refresh_anim()
    self.anim = self:get_anim()
    self.anim:start(self.prop)
end

function Costume:set_pose(pose)
    if pose == self.pose then return end
    
    self.last_pose = self.pose

    if self.poses[pose] then
        self.pose = pose
        self:refresh_anim()
    else
        print("Failed to set pose", pose)
    end
end

function Costume:set_direction(newdir, without_turning)
    if type(newdir) == "userdata" then
        local dir = 5
        
        if math.abs(newdir.x) > math.abs(newdir.y) then
            if newdir.x > 0 then
                dir = 6
            else
                dir = 4
            end
        else
            if newdir.y > 0 then
                dir = 2
            else
                dir = 8
            end
        end
        
        self:set_direction(dir, without_turning)
        return
    end

    if newdir == self.direction then return end

    local olddir = self.direction
    local turndir = olddir * 10 + newdir

    if self.poses.turn and self.poses.turn[turndir] and not without_turning then
        self.direction = turndir
        self:get_pose("turn")
    else
        self.direction = newdir
        self:refresh_anim()
    end
end

function Costume:update(elapsed)
    self.anim:update(elapsed)
    
    if self.anim:getTimesExecuted() >= 1 and not self.anim.loops then
        if self.pose == "turn" then
            self:set_direction(self.direction % 10, true)
        end
        
        self:set_pose(self.last_pose)
    end
end