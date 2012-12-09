mrequire "classes/class"

costumes = { }

--------------------------------------------------

newclass("Costume",
    function()
        return { poses = { } }
    end
)

function Costume:addPose(pose, dir, path, frames, w, h, loops)
    loops = loops or false

    local curve = MOAIAnimCurve.new()
    curve:reserveKeys(frames)
    
    for i = 1, frames do
        curve:setKey(i, (i - 1) / frames, i, MOAIEaseType.FLAT)
    end
    curve:setKey(frames, 1, 1, MOAIEaseType.FLAT)
    
    local img = MOAIImageTexture.new()
    img:load(path, MOAIImage.TRUECOLOR + MOAIImage.PREMULTIPLY_ALPHA)

    local deck = MOAITileDeck2D.new()
    deck:setTexture(img)
    deck:setSize(frames, 1)
    deck:setRect(-w, 0, w, -h * 2)
    deck.img = img
    
    if not self.poses[pose] then
        self.poses[pose] = { }
    end
    
    self.poses[pose][dir] = {
        deck = deck,
        curve = curve,
        texture = img,
        loops = loops,
        hotspots = { }
    }
end

function Costume:addHotspot(pose, dir, hotspot)
    if self.poses[pose] and self.poses[pose][dir] then
        self.poses[pose][dir].hotspots[hotspot.id] = hotspot
    end
end

function Costume:getPose(pose, direction)
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

--------------------------------------------------

newclass("CostumeController",
    function(costume)
        return {
            costume = costume,
            direction = 2,
            poses = { },
            pose = "idle",
            last_pose = "idle",
            anim = nil,
            prop = nil,
            texture = nil
        }
    end
)

function CostumeController:setProp(prop)
    self.prop = prop
end


function CostumeController:start()
    pose = self.costume:getPose(self.pose, self.direction)

    self.prop:setDeck(pose.deck)
    self.prop:setIndex(1)
    
    if self.anim then
        self.anim:detach()
    end
    
    local anim = MOAIAnim.new()
    anim:reserveLinks(1)
    anim:setLink(1, pose.curve, self.prop, MOAIProp2D.ATTR_INDEX)
    
    anim:setMode(pose.loops and MOAITimer.LOOP or MOAITimer.NORMAL)
    anim:start()
    
    self.anim = anim
    self.texture = pose.deck.img
end

function CostumeController:stop()
    self.anim:detach()
end

function CostumeController:refresh()
    self:start()
end

function CostumeController:hitTest(x, y, xscale, yscale)
    local rx, rh, rw, ry = self.prop:getRect()
    local lx, ly = self.prop:getLoc()
    
    local x0 = rx * xscale + lx
    local y0 = ry * yscale + ly
    
    local width = math.max(rx, rw) - math.min(rx, rw)
    local height = math.max(ry, rh) - math.min(ry, rh) 
    
    -- get local space coords
    x0 = (x - x0) / xscale
    y0 = (y - y0) / yscale
    
    if y0 < 0 then
        y0 = y0 + height
    end
    
    -- get bitmap coords
    x = x0 + (self.prop:getIndex() - 1) * width
    y = y0
    
    local _, _, _, a = self.texture:getRGBA(x, y)
    if a ~= 0 then
        local pose = self.costume:getPose(self.pose, self.direction)
        
        local hs = Hotspot.hitTest(pose.hotspots, x0, y0)
        return hs or true
    end
    
    return nil
end

function CostumeController:setPose(pose, dir)
    dir = dir or self.direction
    
    self.last_pose = self.pose
    self.direction = dir
    self.pose = pose

    if self.costume.poses[pose] then
        self:start(pose, dir)
    else
        print("Failed to set pose", pose)
    end
end

function CostumeController:setDirection(newdir, without_turning)
    if type(newdir) == "table" then
        local dir = 5
        local x, y = unpack(newdir)
        
        if math.abs(x) > math.abs(y) then
            if x == y then return end
            
            if x > 0 then
                dir = 6
            else
                dir = 4
            end
        else
            if x == y then return end
        
            if y > 0 then
                dir = 2
            else
                dir = 8
            end
        end
        
        self:setDirection(dir, without_turning)
        return
    end

    if newdir == self.direction then return end

    local olddir = self.direction
    
    if self.costume.poses.turn and self.costume.poses.turn[turndir] and not without_turning then
        self:setPose("turn", turndir)
    else
        self:setPose(self.pose, newdir)
    end
end
