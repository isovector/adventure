--- Provides the vim-like command line interface.

mrequire "classes/class"

--- The Vim class.
-- Constructor signature is ().
-- @newclass Vim
newclass("Vim", 
    function()
        return {
            buffer = "",
            mode = "normal",
            modes = { },
            mode_stack = { },
            change_callbacks  = { }
        }
    end
)

--- Returns a string representation of the buffer or, if empty,  the name of the current 
-- mode.
function Vim:getBufferText()
    if self.buffer == "" then
        return "-- " .. string.upper(self.mode) .. " --"
    end
    
    return self.buffer
end

--- Adds a character to the buffer.
-- @param char
function Vim:addChar(char)
    self.buffer = self.buffer .. char
    self:change()
    self:check()
end

--- Simulates pressing backspace on the buffer.
function Vim:backspace()
    self.buffer = self.buffer:sub(1, #self.buffer - 1)
    self:change()
end

--- Internal method called whenever the buffer changes, used to manage change 
-- callbacks.
function Vim:change()
    if #self.change_callbacks == 0 then return end

    for i = 1, #self.change_callbacks do
        self.change_callbacks[i]()
    end
    
    self.change_callbacks = { }
end

--- Register a function to be called when the buffer changes.
-- @param callback
function Vim:addChangeCallback(callback)
    table.insert(self.change_callbacks, callback)
end

--- Sets the current mode. If no_history is set, the current mode will not be put onto 
-- the history stack.
-- @param mode
-- @param no_history
function Vim:setMode(mode, no_history)
    local old = self.mode
    if not no_history then
        table.insert(self.mode_stack, old)
    end

    if self.modes[old].onExit then
        self.modes[old].onExit(mode)
    end

    self.mode = mode
    
    if self.modes[mode].onEnter then
        self.modes[mode].onEnter(old)
    end
end

--- Pops a mode off of the history stack.
function Vim:popMode()
    local idx = #self.mode_stack
    
    if idx == 0 then
        self:setMode("normal", true)
        return
    end
    
    self:setMode(self.mode_stack[idx], true)
    table.remove(self.mode_stack, idx)
end

--- Clears the buffer. If change_mode is on, simulates pressing <ESC> in Vim.
-- @param change_mode
function Vim:clear(change_mode)
    self:change()
    if self.buffer == "" and change_mode then
        self:popMode()
    else
        self.buffer = ""
    end
end

--- Checks if a command matches any commands registered in a given mode.
-- @param mode
-- @param cmd
-- @param args
function Vim:checkModeCmd(mode, cmd, args)
    for _, entry in ipairs(self.modes[mode].commands) do
        if cmd == entry.cmd then
            entry.action(unpack(args))
            self:clear()
            return true
        end
    end
    
    return false
end

--- Called when the buffer is submitted (ie: <RET> in Vim).
function Vim:send()
    local buffer = self.buffer
    
    if #buffer == 0 or buffer:sub(1, 1) ~= ":" then
        self:clear()
        return
    end
    
    buffer = buffer:sub(2)
    
    local args = { }
    local cmd = nil
    for token in buffer:gmatch("[^%s]+") do
        if not cmd then 
            cmd = token
        else
            table.insert(args, token)
        end
    end
    
    if self:checkModeCmd(self.mode, cmd, args) then
        return
    end
    
    self:checkModeCmd("global", cmd, args)
    self:clear()
end

--- Checks whether any buffer actions match the buffer.
function Vim:check()
    local buffer = self.buffer
    local cleared = false
    for _, bind in ipairs(self.modes[self.mode].buffs) do
        local result = { buffer:match(bind.cmd) }
    
        if #result ~= 0 then
            bind.action(unpack(result))
            
            if bind.cmd:sub(-1) == "$" then
                cleared = true
            end
        end
    end
    
    if cleared then
        self:clear()
    end
end

--- Adds a new mode, calling enter when entering, and exit when exiting.
-- @param mode
-- @param enter
-- @param exit
function Vim:createMode(mode, enter, exit)
    if not self.modes[mode] then
        self.modes[mode] = { commands = { }, buffs = { }, onEnter = enter, onExit = exit }
    else
        if enter then
            self.modes[mode].onEnter = enter
        end
        
        if exit then
            self.modes[mode].onExit = exit
        end
    end
end

--- Adds a new buffer action. Cmd should be regex to be matched on the buffer.
-- @param mode
-- @param cmd
-- @param action
function Vim:buf(mode, cmd, action)
    self:createMode(mode)

    table.insert(self.modes[mode].buffs, { cmd = cmd, action = action })
end

local function build_command(t, cmd, action)
    local first, last = cmd:match("(%w+)|(%w+)")
    
    if first then
        table.insert(t, { cmd = first .. last, action = action })
        cmd = first or cmd
    end
    
    table.insert(t, { cmd = cmd, action = action })
end

--- Adds a new command to the Vim. Command should be of the form "ac|tion", where
-- the pipe indicates the break for a shortcut.
-- @param mode
-- @param cmd
-- @param action
function Vim:cmd(mode, cmd, action)
    self:createMode(mode)

    build_command(self.modes[mode].commands, cmd, action)
end
