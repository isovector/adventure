local sheet = Sheet.new("foreground")

local perfect = PixelPerfect.new("../game/costumes/santino/idle.png")
local prop = MOAIProp2D.new()
local quad = perfect:apply(prop)
quad:setRect(0, 0, 1920, 120)
quad:setUVRect(0, 0, 1, 1)
prop:setLoc(500, 500)

local santino = MOAIProp2D.new()
santino:setLoc(400, 400)
sheet:insertProp(santino)
costumes.santino:bind(santino)
costumes.santino:refresh_anim()

sheet:insertProp(prop)
sheet:pushRenderPass()

sheet:installHover(true)

function sheet:onHover(prop, x, y)
    if not prop.pixelPerfect or prop.pixelPerfect:check(prop, x, y) then
        textbox:setString("hello")
        mouse.cursor = 5
        
        return true
    end
    
    return false
end
