require "classes/class"

local viewport = viewport

newclass("Sheet",
    function(id)
        local layer = MOAILayer2D.new()
        layer:setViewport(viewport)
        
        local partition = MOAIPartition.new()
        layer:setPartition(partition)
    
        local self = {
            id = id,
            layer = layer,
            partition = partition,
            click_allowed = false,
            hover_allowed = false,
            gfx_allowed = true,
            enabled = true
        }
        
        return self
    end
)

local sheets = { }

local function rebuild_sheet_table()
    local render = { }
    
    for _, sheet in ipairs(sheets) do
        if sheet.enabled and sheet.gfx_allowed then
            table.insert(render, sheet.layer)
        end
    end
    
    MOAIRenderMgr.setRenderTable(render)
end

function Sheet.beforeDraw(self)
    -- this is a static and an instance method
    if self then return end

    for i = 1, #sheets do
        if sheets[i].enabled then
            sheets[i]:beforeDraw()
        end
    end
end

function Sheet.afterDraw(self)
    -- this is a static and an instance method
    if self then return end

    for i = 1, #sheets do
        if sheets[i].enabled then
            sheets[i]:afterDraw()
        end
    end
end

function Sheet.hover(x, y)
    for n = #sheets, 1, -1 do
        local sheet = sheets[n]
    
        if sheet.enabled and sheet.hover_allowed and sheet:hoverCallback(x, y) then
            return sheet
        end
    end
    
    return false
end

function Sheet.click(x, y, down)
    for n = #sheets, 1, -1 do
        local sheet = sheets[n]
    
        if sheet.enabled and sheet.click_allowed and sheet:clickCallback(x, y, down) then
            return sheet
        end
    end
    
    return false
end

function Sheet.getSheets()
    return sheets
end

function Sheet:hoverCallback(x, y)
    local prop = self.partition:propForPoint(x, y)
    if prop and (not prop.anim or prop.anim:hitTest(prop, x, y)) then
        return not self.onHover or self:onHover(prop, x, y)
    end
    
    return false
end

function Sheet:clickCallback(x, y, down)
    local prop = self.partition:propForPoint(x, y)
    if prop and (not prop.anim or prop.anim:hitTest(prop, x, y)) then
        return not self.onClick or self:onClick(prop, x, y, down)
    end
    
    return false
end

function Sheet:enable(enabled)
    self.enabled = enabled
    rebuild_sheet_table()
end

function Sheet:allowClick(enabled)
    self.click_allowed = enabled
end

function Sheet:allowHover(enabled)
    self.hover_allowed = enabled
end

function Sheet:allowGraphics(enabled)
    self.gfx_allowed = enabled
end

function Sheet:install()
    table.insert(sheets, self)
    
    if self.gfx_allowed then
        rebuild_sheet_table()
    end
end

function Sheet:insertProp(prop)
    self.layer:insertProp(prop)
    self.partition:insertProp(prop)
end

function Sheet:removeProp(prop)
    self.layer:removeProp(prop)
    self.partition:removeProp(prop)
end
