local sheet = Sheet.new("foreground")
local quad = MOAIGfxQuad2D.new()
quad:setTexture("../game/costumes/santino/idle.png")
quad:setRect(0, 0, 256, 256)
quad:setUVRect(0, 0, 1, 1)

local santino = MOAIProp2D.new()
santino:setLoc(400, 400)
sheet:insertProp(santino)
costumes.santino:bind(santino)
costumes.santino:refresh_anim()

local prop = MOAIProp2D.new()
prop:setDeck(quad)
prop:setLoc(500, 500)

sheet:insertProp(prop)
sheet:pushRenderPass()

sheet:installHover(true)

function sheet:onHover(prop, x, y)
    textbox:setString("hello")
    mouse.cursor = 5
    return prop
end
