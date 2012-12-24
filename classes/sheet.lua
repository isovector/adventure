--- A more fully-featured version of MOAI's layer class.
-- Sheets are individual drawing layers. They are automatically
-- managed and provide common functionality hooks.

mrequire "classes/class"
mrequire "classes/labeler"

local viewport = viewport

--- The Sheet class.
-- Constructor signature is (id).
-- @newclass Sheet
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

--- Recreates MOAI's RenderMgr render table.
local function rebuild_sheet_table()
    local render = { }
    
    for _, sheet in ipairs(sheets) do
        if sheet.enabled and sheet.needs_draw then
            table.insert(render, sheet.layer)
        end
    end
    
    MOAIRenderMgr.setRenderTable(render)
end

--- Static method to globally set the input state.
-- @param enabled
function Sheet.enableInput(enabled)
    inputEnabled = enabled
end

--- Internal static method to call onBeforeDraw hooks.
-- This should not be called by user code.
function Sheet.dispatchBeforeDraw()
    for i = 1, #sheets do
        local method = sheets[i].onBeforeDraw
        if sheets[i].enabled and method then
            method(sheets[i])
        end
    end
end

--- Internal static method to call onAfterDraw hooks.
-- This should not be called by user code.
function Sheet.dispatchAfterDraw()
    for i = 1, #sheets do
        local method = sheets[i].onAfterDraw
        if sheets[i].enabled and method then
            method(sheets[i])
        end
    end
end

--- Internal static method to interpret hover hooks according to the hoverAcceptor.
-- This should not be called by user code.
-- @param x
-- @param y
-- @see Sheet:setHoverAcceptor
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

--- Internal static method to interpret click hooks according to the clickAcceptor.
-- This should not be called by user code.
-- @param x
-- @param y
-- @param down
-- @see Sheet:setClickAcceptor
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

--- Internal static method to interpret click hooks according to the rClickAcceptor.
-- This should not be called by user code.
-- @param x
-- @param y
-- @param down
-- @see Sheet:setRClickAcceptor
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

--- Gets the Sheet stack.
-- @return A table of all registered Sheets
function Sheet.getSheets()
    return sheets
end

--- Gets a Sheet by id.
-- @param id The Sheet id
-- @return The requested Sheet
function Sheet.getSheet(id)
    for i = 1, #sheets do
        if sheets[i].id == id then
            return sheets[i]
        end
    end
    
    return nil
end

--- An acceptor which binds only to props registered on the Sheet.
-- This function should never be called by user code, but instead used as an argument
-- to Sheet:setXAcceptor.
-- The callback will receive (prop, x, y, ...).
-- @param callback
-- @param x
-- @param y
-- @param ...
function Sheet:prop_acceptor(callback, x, y, ...)
    local propList = { self.partition:propListForPoint(x, y, 0, MOAILayer.SORT_PRIORITY_DESCENDING) }
    for _, prop in ipairs(propList) do
        if prop and (not prop.actor or prop.actor:hitTest(x, y)) then
            return not callback or callback(self, prop, x, y, ...)
        end
    end
    
    return nil
end

--- An acceptor which always binds.
-- This function should never be called by uesr code, but instead used as an argument
-- to Sheet:setXAcceptor.
-- The callback will receive (prop, x, y, ...), where prop is nil if one doesn't exist at (x, y)
-- @param callback
-- @param x
-- @param y
-- @param ...
function Sheet:all_acceptor(callback, x, y, ...)
    local ret = self:prop_acceptor(callback, x, y, ...)
    
    if ret == nil then
        return not callback or callback(self, nil, x, y, ...)
    end
    
    return ret
end

--- Sets the enabled state of the Sheet. Disabled Sheets receive no input and cannot be seen.
-- @param enabled
function Sheet:enable(enabled)
    self.enabled = enabled
    rebuild_sheet_table()
end

--- Associates a Sheet.x_acceptor with the current Sheet's click hook. 
-- When the acceptor binds, Sheet:onClick will be called with (prop, x, y, down)
-- @param acceptor Either Sheet.prop_acceptor or Sheet.all_acceptor
function Sheet:setClickAcceptor(acceptor)
    self.clickAcceptor = acceptor
end

--- Associates a Sheet.x_acceptor with the current Sheet's right click hook. 
-- When the acceptor binds, Sheet:onRClick will be called with (prop, x, y, down)
-- @param acceptor Either Sheet.prop_acceptor or Sheet.all_acceptor
function Sheet:setRClickAcceptor(acceptor)
    self.rClickAcceptor = acceptor
end

--- Associates a Sheet.x_acceptor with the current Sheet's hover hook. 
-- When the acceptor binds, Sheet:onHover will be called with (prop, x, y)
-- @param acceptor Either Sheet.prop_acceptor or Sheet.all_acceptor
function Sheet:setHoverAcceptor(acceptor)
    self.hoverAcceptor = acceptor
end

--- Sets whether or not to draw this Sheet. Setting false implies the Sheet
-- can still receive input.
-- @param enabled
function Sheet:needsDraw(enabled)
    self.needs_draw = enabled
end

--- Hooks the given Sheet into the global Sheet collection, to be automatically
-- managed henceforth.
function Sheet:install()
    table.insert(sheets, self)
    
    if self.needs_draw and self.enabled then
        rebuild_sheet_table()
    end
end

--- Adds a prop to the Sheet. The prop is automatically given raycast detection
-- for prop acceptor management.
-- @param prop A MOAIProp
function Sheet:insertProp(prop)
    self.layer:insertProp(prop)
    self.partition:insertProp(prop)
end

-- Removes a prop from the Sheet.
-- @param prop A MOAIProp previously inserted
function Sheet:removeProp(prop)
    self.layer:removeProp(prop)
    self.partition:removeProp(prop)
end

--- Returns the Sheet's associated Labeler.
-- The first call of this function will create a new labeler.
-- @see Labeler:addLabel
function Sheet:getLabeler()
    if not self.labeler then
        self.labeler = Labeler.new(self.layer, "assets/static/arial-rounded.TTF")
    end
    
    return self.labeler
end
