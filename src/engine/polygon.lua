--- A wrapper around HardonCollider's polygon shapes.
-- This provides convenient runtime polygon collision detection.

mrequire "src/class"
local Shapes = require "src/lib/HardonCollider/shapes"

--- The Polygon class.
-- Constructor signature is (first, ...).
-- @newclass Polygon
newclass("Polygon", 
    function(first, ...)
        local points
        
        if type(first) == "table" then
            points = first
        else
            points = { first, ... }
        end
    
        return {
            points = points,
            shape = nil
        }
    end
)

--- Adds a point to the Polygon.
function Polygon:addPoint(x, y)
    table.insert(self.points, x)
    table.insert(self.points, y)
    self:invalidate()
end

--- Removes the last added point from the Polygon.
function Polygon:removePoint()
    table.remove(self.points, #self.points)
    table.remove(self.points, #self.points)
    self:invalidate()
end

--- Returns the number of points in the Polygon.
function Polygon:size()
    return #self.points / 2
end

--- Informs the internal collision detection to rebuild it's
-- associated mesh. This is automatically called whenever
-- points are added or removed.
function Polygon:invalidate()
    self.shape = nil
end

--- Creates a new Hardon polygon shape corresponding to this
-- polygon.
function Polygon:rebuildCollision()
    if self.shape or #self.points < 6 then return end
    
    self.shape = Shapes.newPolygonShape(unpack(self.points))
end

--- Determines if a ray at (x, y) will hit this Polygon.
function Polygon:hitTest(x, y)
    self:rebuildCollision()
    
    if self.shape then
        return self.shape:contains(x, y)
    end
    
    return false
end

function Polygon:lineTest(ax,ay, bx,by)
    self:rebuildCollision()
    
    if self.shape then
        return self.shape:intersectsLine(bx,by, ax,ay)
    end
    
    return false
end

function Polygon:getBox()
    self:rebuildCollision()

    if self.shape then
        return self.shape:getBBox()
    end
    
    return 0, 0, 0, 0
end

function Polygon:__serialize(f, indent)
    f:write(string.format("%sPolygon.new({\n", indent))
    for i = 1, #self.points, 2 do
        f:write(string.format("%s    %d, %d,\n", indent, self.points[i], self.points[i + 1]))
    end
    f:write(string.format("%s})", indent))
end
