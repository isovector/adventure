-- 
--  test.lua
--  lua-astar
--  
--  Created by Jay Roberts on 2011-01-12.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 
--  This is a simple test script which demonstrates the AStar class in use.
--


require 'classes/lib/lua-astar/astar'
require 'classes/lib/lua-astar/volumehandler'


local handler = VolumeHandler()
local astar = AStar(handler)

handler:setSize(2, 2)
print(handler.width)

local start = {
 x = 2,
 y = 2
}

local goal = {
  x = 22,
  y = 22
}

local path = astar:findPath(start, goal)

for _, node in pairs(path:getNodes()) do
    print("path ", node.location.x, node.location.y)
end



print 'Done'
