require "classes/game"
require "classes/sheet"

local sheet = Sheet.new("background")
local quad = MOAIGfxQuad2D.new()
quad:setRect(0, 0, 1280, 720)
quad:setUVRect(0, 0, 1, 1)

local prop = MOAIProp2D.new()
prop:setDeck(quad)

sheet:insertProp(prop)
sheet:install()

sheet:allowClick(true)
sheet:allowHover(true)

local function setBackground(path)
    quad:setTexture(path)
end
game.export("setBackground", setBackground)


function sheet:onHover()
    game.setHoverText("")
    game.setCursor(0)
    return true
end

local first = nil

function sheet:onClick(prop, x, y, down)
    local res = room.astar.resolution
    local pos = { x = math.floor(x / res) + 1, y = math.floor(y / res) + 1 }
    
    if not down then return true end
    
    if not first then
        first = pos
        
        game.addVisualization(function()
            MOAIGfxDevice.setPenColor(0, 0, 1)
            MOAIDraw.fillRect((pos.x - 1) * res, (pos.y - 1) * res, pos.x * res, pos.y * res)
        end, 3)
        
        return true
    end

    local path = room:getPath(first, pos, { w = 2, h = 2  })
    local f = first
    game.addVisualization(function()
        local points = { f.x * res - res / 2, f.y * res - res / 2 }
    
        for i, node in ipairs(path) do
            table.insert(points, (node.location.x - 1) * res + res / 2)
            table.insert(points, (node.location.y - 1) * res + res / 2)
        end
        
        MOAIGfxDevice.setPenColor(0, 1, 0)
        MOAIDraw.drawLine(points)
    end, 5)
    
    first = nil
    
    return true
end
