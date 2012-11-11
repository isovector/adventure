require "classes/class"
require "classes/labeler"

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
            needs_draw = true,
            enabled = true,
            
            -- Handlers which determine if the sheet should handle an event
            clickAcceptor = nil,
            rClickAcceptor = nil,
            hoverAcceptor = nil,
            
            labeler = nil
        }
        
        return self
    end
)

local inputEnabled = true
local sheets = { }

local function rebuild_sheet_table()
    local render = { }
    
    for _, sheet in ipairs(sheets) do
        if sheet.enabled and sheet.needs_draw then
            table.insert(render, sheet.layer)
        end
    end
    
    MOAIRenderMgr.setRenderTable(render)
end

function Sheet.enableInput(enabled)
    inputEnabled = enabled
end

function Sheet.dispatchBeforeDraw()
    for i = 1, #sheets do
        local method = sheets[i].onBeforeDraw
        if sheets[i].enabled and method then
            method(sheets[i])
        end
    end
end

function Sheet.dispatchAfterDraw()
    for i = 1, #sheets do
        local method = sheets[i].onAfterDraw
        if sheets[i].enabled and method then
            method(sheets[i])
        end
    end
end

function Sheet.dispatchHover(x, y)
    if not inputEnabled then return nil end

    for n = #sheets, 1, -1 do
        local sheet = sheets[n]
    
        if sheet.enabled and sheet.hoverAcceptor and sheet:hoverAcceptor(sheet.onHover, x, y) then
            return sheet
        end
    end
    
    return nil
end

function Sheet.dispatchClick(x, y, down)
    if not inputEnabled then return nil end

    for n = #sheets, 1, -1 do
        local sheet = sheets[n]
    
        if sheet.enabled and sheet.clickAcceptor and sheet:clickAcceptor(sheet.onClick, x, y, down) then
            return sheet
        end
    end
    
    return nil
end

function Sheet.dispatchRClick(x, y, down)
    if not inputEnabled then return nil end

    for n = #sheets, 1, -1 do
        local sheet = sheets[n]
    
        if sheet.enabled and sheet.rClickAcceptor and sheet:rClickAcceptor(sheet.onRClick, x, y, down) then
            return sheet
        end
    end
    
    return nil
end

function Sheet.getSheets()
    return sheets
end

function Sheet.getSheet(id)
    for i = 1, #sheets do
        if sheets[i].id == id then
            return sheets[i]
        end
    end
    
    return nil
end

function Sheet:prop_acceptor(callback, x, y, ...)
    local prop = self.partition:propForPoint(x, y)
    if prop and (not prop.actor or prop.actor.costume:hitTest(x, y)) then
        return not callback or callback(self, prop, x, y, ...)
    end
    
    return false
end

function Sheet:all_acceptor(callback, x, y, ...)
    local prop = self.partition:propForPoint(x, y)
    if prop and (not prop.actor or prop.actor.costume:hitTest(x, y)) then
        return not callback or callback(self, prop, x, y, ...)
    end
    
    return not callback or callback(self, nil, x, y, ...)
end

function Sheet:enable(enabled)
    self.enabled = enabled
    rebuild_sheet_table()
end

function Sheet:setClickAcceptor(acceptor)
    self.clickAcceptor = acceptor
end

function Sheet:setRClickAcceptor(acceptor)
    self.rClickAcceptor = acceptor
end

function Sheet:setHoverAcceptor(acceptor)
    self.hoverAcceptor = acceptor
end

function Sheet:needsDraw(enabled)
    self.needs_draw = enabled
end

function Sheet:install()
    table.insert(sheets, self)
    
    if self.needs_draw and self.enabled then
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

function Sheet:getLabeler()
    if not self.labeler then
        self.labeler = Labeler.new(self.layer, "assets/static/arial-rounded.TTF")
    end
    
    return self.labeler
end
