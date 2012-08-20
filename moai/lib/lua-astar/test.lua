-- 
--  test.lua
--  lua-astar
--  
--  Created by Jay Roberts on 2011-01-12.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 
--  This is a simple test script which demonstrates the AStar class in use.
--


require 'lib/lua-astar/astar'
require 'lib/lua-astar/tiledmaphandler'


local handler = TiledMapHandler()
local astar = AStar(handler)

print 'Beginning...'

   local start = {
     x = math.random(1, 23),
     y = math.random(1, 23)
   }

   local goal = {
      x = math.random(1, 23),
      y = math.random(1, 23)
   }
   
   print(string.format('Testing: (%i, %i) (%i, %i)', start.x, start.y, goal.x, goal.y))
   
   local path = astar:findPath(start, goal)



print 'Done'
