-- 
--    Volumehandler.lua
--    lua-astar
--    
--    Created by Jay Roberts on 2011-01-12.
--    Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'classes/lib/lua-astar/middleclass'

VolumeHandler = class('VolumeHandler')


function VolumeHandler:initialize(tiles)
    self.width = 1
    self.height = 1

    self.tiles = tiles
end

function VolumeHandler:setSize(w, h)
    self.width = w or 1
    self.height = h or 1
end

function VolumeHandler:getRect(query)
    local x, y

    if self.width % 2 == 0 then
        x = query.x - self.width / 2 + 1
    else
        x = query.x - (self.width - 1) / 2
    end
    
    if self.height % 2 == 0 then
        y = query.y - self.height / 2 + 1
    else
        y = query.y - (self.height - 1) / 2
    end
    
    return { x = x, y = y }
end

function VolumeHandler:getNode(location)
    local rect = self:getRect(location)

    -- Here you make sure the requested node is valid (i.e. on the self.tiles, not blocked)
    if location.x + self.width > #self.tiles[1] or location.y + self.height > #self.tiles then
        return nil
    end

    if location.x < 1 or location.y < 1 then
        return nil
    end
    
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local x = rect.x + x
            local y = rect.y + y
        
            if not (self.tiles[y][x] == 0) then
                return nil
            end
        end
    end

    return Node(location, 1, location.y * #self.tiles[1] + location.x)
end


function VolumeHandler:getAdjacentNodes(curnode, dest)
    local cl = curnode.location
    local dl = dest

    local result = { }
    for j = 1, 3 do
        local dy = j - 2
        for i = 1, 3 do
            local dx = i - 2
            
            if not (dx == 0 and dy == 0) then
                local n = self:_handleNode(cl.x + dx, cl.y + dy, curnode, dl.x, dl.y)
                if n then
                    table.insert(result, n)
                end
            end
        end
    end

    return result
end

function VolumeHandler:locationsAreEqual(a, b)
    return a.x == b.x and a.y == b.y
end

function VolumeHandler:_handleNode(x, y, fromnode, destx, desty)
    -- Fetch a Node for the given location and set its parameters
    local loc = {
        x = x,
        y = y
    }
    
    local diag_bias = math.abs(x - fromnode.location.x) +
                        math.abs(y - fromnode.location.y)
    
    local n = self:getNode(loc)
    
    if n ~= nil then
        local dx = math.max(x, destx) - math.min(x, destx)
        local dy = math.max(y, desty) - math.min(y, desty)
        local emCost = dx + dy
        
        n.mCost = n.mCost + fromnode.mCost
        n.score = n.mCost + emCost + diag_bias * 3
        n.parent = fromnode
        
        return n
    end
    
    return nil
end
