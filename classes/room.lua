--- Rooms are locations that may contain Actors.
-- They consist of a backdrop, Actors, Hotspots, and doors.
-- Rooms are created via the room editor, and are automatically loaded via the 3-load-rooms.lua service.

mrequire "classes/class"
mrequire "classes/hotspot"
mrequire "classes/interpolator"
mrequire "classes/polygon"
mrequire 'classes/lib/lua-astar/astar'
mrequire 'classes/lib/lua-astar/volumehandler'

--- A global pointing at the current room
room = { }

local rooms = { }

--- The Room class.
-- Constructor signature is (id, path).
-- @newclass Room
newclass("Room", 
    function(id, path)
        local perspective = Interpolator.new()
        perspective[0] = 1
        perspective[720] = 1

        local room = { 
            id = id, 
            img_path = path,
            hotspots = { },
            scene = { },
            events = { },
            
            perspective = perspective,
            
            handler = nil,
            astar = nil,
            walkPolygon = nil,
            
            onLoad = nil
        }
        
        rooms[id] = room
        return room
    end
)

--- Static method to get a room by id.
-- @param id
function Room.getRoom(id)
    id = id or room.id

    return rooms[id]
end

--- Static method to change the current room.
-- @param id
function Room.change(id)
    if rooms[id] then
        room:unload()
        rooms[id]:load()
    end
end

--- Internal method to create a nav mesh.
-- User code should never call this.
-- @param polys A table of alternating x, y coordinates of polygon vertices
function Room:installPathing(polys)
    local res = 16
    
    local hs = Polygon.new(unpack(polys))
    local map = { }
    
    for y = 1, 720 / res do
        local row = { }
        for x = 1, 1280 / res do
            local sx, sy = x * res - res / 2, y * res - res / 2
            
            if hs:hitTest(sx, sy) then
                row[x] = 0
            else
                row[x] = 1
            end
        end
        map[y] = row
    end

    local handler = VolumeHandler(map)
    local astar = AStar(handler)
    astar.resolution = res
    astar.polys = polys
    
    self.handler = handler
    self.astar = astar
    self.walkPolygon = hs
end

--- Add a Hotspot to the room.
-- @param hotspot
function Room:addHotspot(hotspot)
    table.insert(self.hotspots, hotspot)
end

--- Remove a hotspot from the room.
-- @param id The id of the Hotspot to remove
function Room:removeHotspot(id)
    for i = 1, #self.hotspots do
        if self.hotspots[i].id == id then
            table.remove(self.hotspots, i)
            return
        end
    end
end

--- Turns a world space location into a pathing map node.
-- @return A table of (x => x, y => y) which can be fed into lua-astar
function Room:locToPos(x, y)
    local res = self.astar.resolution
    return { x = math.floor(x / res) + 1, y = math.floor(y / res) + 1 }
end

--- Turns a pathing map node into a world space location.
-- @param node The result of a locToPos or pathfinding node
-- @return x
-- @return y
function Room:nodeToLoc(node)
    if not node then return 0, 0 end
    
    local loc = node.location
    local res = self.astar.resolution
    
    return loc.x * res - res / 2, loc.y * res - res / 2
end

--- Shortens an A* path by bisection of intersecting edges
-- @param nodes The calculated A* path
-- @param poly The navmesh (this doesn't appear to be used)
-- @param low The lower bound of the recursion
-- @param high The upper bound of the recursion
-- @return A smoother path than the one given by A*
function Room:shortenPath(nodes, poly, low, high)
    if high <= low then
        return { { self:nodeToLoc(nodes[low]) } }
    end

    local ax,ay = self:nodeToLoc(nodes[low])
    local bx,by = self:nodeToLoc(nodes[high])
    
    if self.walkPolygon:lineTest(ax,ay, bx,by) then
        local mid = math.floor((high - low) / 2) + low
    
        local a = self:shortenPath(nodes, poly, low, mid)
        local b = self:shortenPath(nodes, poly, mid + 1, high)
    
        for _, node in ipairs(b) do
            table.insert(a, node)
        end
        
        return a
    end
    
    return { {ax,ay}, {bx,by} }
end

--- Calculates a path against the navmesh
-- @param sx Source x
-- @param sy Source y
-- @param dx Destination x
-- @param dy Destination y
-- @param w The width of the pathfinder
-- @param h The height of the pathfinder
function Room:getPath(sx, sy, dx, dy, w, h)
    if not self.astar then return nil end

    local src = self:locToPos(sx, sy)
    local dst = self:locToPos(dx, dy)
    
    if src.x == dst.x and src.y == dst.y then
        return { }
    end
    
    w = w or 1
    h = h or 1
    
    self.handler:setSize(w, h)
    path = self.astar:findPath(src, dst)
    
    if not path then return { } end
    
    local nodes = path:getNodes()
    return self:shortenPath(nodes, self.walkPolygon, 1, #nodes)
end

--- Initializes a room.
-- Sets the backdrop, hotspots, joins Actors, and calls the reload script.
function Room:load()
    room = self
    game.setBackground(self.img_path)
    game.setHotspots(self.hotspots)
    
    for _, entry in pairs(self.scene) do
        local actor = entry.actor
        
        actor:joinScene()
        actor:teleport(entry.x, entry.y)
    end
    
    if self.onLoad then
        self:onLoad()
    end
    
    self:reload()
end

--- Calls the reload script.
-- Called whenever a room is entered or a save is loaded.
function Room:reload()
    if self.events.__utility and self.events.__utility.reload then
        self.events.__utility.reload()
    end
end

--- Cleans up a room when another is being loaded.
function Room:unload()
    room = nil
    game.setHotspots({ })

    for _, entry in pairs(self.scene) do
        entry.actor:leaveScene()
    end
end

--- Adds an Actor to the scene graph.
-- @param actor A real actor (not an id)
function Room:addActor(actor, x, y)
    if not self.scene[actor.id] then
        local entry = { actor = actor, x = x, y = y }
        self.scene[actor.id] = entry
        
        if room == self then
            actor:joinScene()
            actor:teleport(x, y)
        end
    else
        local entry = self.scene[actor.id]
    
        entry.x = x
        entry.y = y
        entry.actor:teleport(x, y)
    end
end

--- Removes an Actor from the scene graph.
-- @param actor
function Room:removeActor(actor)
    self.scene[actor.id] = nil
    
    if room == self then
        actor:leaveScene()
    end
end
