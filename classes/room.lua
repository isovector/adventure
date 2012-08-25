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
            scene = { }
        }
        
        rooms[id] = room
        return room
    end
)

function Room.getRoom(id)
    id = id or room.id

    return rooms[id]
end

function Room:installPathing(map)
    local handler = VolumeHandler(map.map)
    local astar = AStar(handler)
    astar.resolution = map.resolution
    
    self.handler = handler
    self.astar = astar
end

function Room:addHotspot(hotspot)
    table.insert(self.hotspots, hotspot)
end

function Room:getPath(from, to, size)
    if not self.astar then return nil end

    size = size or { w = 1, h = 1 }
    
    self.handler:setSize(size.w, size.h)
    path = self.astar:findPath(from, to)
    
    if not path then return { } end
    return path:getNodes()
end

function Room:load()
    room = self
    game.setBackground(self.img_path)
    game.setHotspots(self.hotspots)
    
    for _, entry in pairs(self.scene) do
        local actor = entry.actor
        
        actor:joinScene()
        actor:move(entry.x, entry.y)
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
    local entry = { actor = actor, x = x, y = y }
    self.scene[actor.id] = entry
end
