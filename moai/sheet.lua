local viewport = viewport

dofile("../scripts/class.lua")

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
            click_installed = false,
            hover_installed = false
        }
        
        return self
    end
)

Sheet.sheets = { }

function Sheet.hover(x, y)
    for n = #Sheet.sheets, 1, -1 do
        local sheet = Sheet.sheets[n]
    
        if sheet.hover_installed and sheet:hoverCallback(x, y) then
            return sheet
        end
    end
    
    return false
end

function Sheet.click(x, y, down)
    for n = #Sheet.sheets, 1, -1 do
        local sheet = Sheet.sheets[n]
    
        if sheet.click_installed and sheet:clickCallback(x, y, down) then
            return sheet
        end
    end
    
    return false
end

function Sheet:hoverCallback(x, y)
    local prop = self.partition:propForPoint(x, y)
    if prop then
        return not self.onHover or self:onHover(prop, x, y)
    end
    
    return prop
end

function Sheet:clickCallback(x, y, down)
    local prop = self.partition:propForPoint(x, y)
    if prop then
        return not self.onClick or self:onClick(prop, x, y, down)
    end
    
    return prop
end

function Sheet:installClick(enabled)
    self.click_installed = enabled
end

function Sheet:installHover(enabled)
    self.hover_installed = enabled
end

function Sheet:pushRenderPass()
    MOAISim.pushRenderPass(self.layer)
    table.insert(Sheet.sheets, self)
end

function Sheet:insertProp(prop)
    self.layer:insertProp(prop)
    self.partition:insertProp(prop)
end