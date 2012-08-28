require "classes/class"
require "classes/hotspot"
require 'classes/lib/lua-astar/astar'
require 'classes/lib/lua-astar/volumehandler'

room = { }

local rooms = { }
newclass("Room", function(id, path)
        local room = { 
            id = id, 
            img_path = path,
            hotspots = { },
            scene = { },
            
            handler = nil,
            astar = nil,
            
            onLoad = nil
        }
        
        rooms[id] = room
        return room
    end
)

function Room.getRoom(id)
    id = id or room.id

    return rooms[id]
end

function Room.change(id)
    if rooms[id] then
        room:unload()
        rooms[id]:load()
    end
end

function Room:installPathing(polys)
    local res = 16
    
    local hs = Hotspot.new(nil, nil, nil, unpack(polys))
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
end

function Room:addHotspot(hotspot)
    table.insert(self.hotspots, hotspot)
end

function Room:locToPos(x, y)
    local res = self.astar.resolution
    return { x = math.floor(x / res) + 1, y = math.floor(y / res) + 1 }
end

function Room:nodeToLoc(node)
    if not node then return 0, 0 end
    
    local loc = node.location
    local res = self.astar.resolution
    
    return loc.x * res - res / 2, loc.y * res - res / 2
end

function Room:getPath(sx, sy, dx, dy, w, h)
    if not self.astar then return nil end

    local src = self:locToPos(sx, sy)
    local dst = self:locToPos(dx, dy)
    
    w = w or 1
    h = h or 1
    
    self.handler:setSize(w, h)
    path = self.astar:findPath(src, dst)
    
    if not path then return { } end
    
    local result = { }
    for _, node in ipairs(path:getNodes()) do
        table.insert(result, { self:nodeToLoc(node) } )
    end
    
    return result
end

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
end

function Room:unload()
    room = nil
    game.setHotspots({ })

    for _, entry in pairs(self.scene) do
        entry.actor:leaveScene()
    end
end

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

function Room:removeActor(actor)
    self.scene[actor.id] = nil
    
    if room == self then
        actor:leaveScene()
    end
end
