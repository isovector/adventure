require "classes/class"

newclass("Vim", 
    function()
        return {
            buffer = "",
            mode = "",
            modes = { }
        }
    end
)

function Vim:getBufferText()
    if self.buffer == "" then
        if self.mode ~= "" then
            return "-- " .. string.upper(self.mode) .. " --"
        end
        
        return "-- NORMAL --"
    end
    
    return self.buffer
end

function Vim:addChar(char)
    self.buffer = self.buffer .. char
    self:check()
end

function Vim:backspace()
    self.buffer = self.buffer:sub(1, #self.buffer - 1)
end

function Vim:setMode(mode)
    if self.modes[self.mode].onExit then
        self.modes[self.mode].onExit()
    end

    self.mode = mode
    
    if self.modes[self.mode].onEnter then
        self.modes[self.mode].onEnter()
    end
end

function Vim:clear()
    if self.buffer == "" then
        self:setMode("")
    else
        self.buffer = ""
    end
end

function Vim:send()
    local buffer = self.buffer
    for _, cmd in ipairs(self.modes[self.mode].commands) do
        if #buffer >= #cmd.cmd and buffer:sub(1, #cmd.cmd) == cmd.cmd then
            cmd.action(buffer:sub(#cmd.cmd + 1), unpack(cmd.args))
            self:clear()
            return
        end
    end
    
    self:clear()
end

function Vim:check()
    local buffer = self.buffer
    for _, bind in ipairs(self.modes[self.mode].buffs) do
        if buffer:match(bind.cmd) ~= nil then
            bind.action(buffer, unpack(bind.args))
            self:clear()
            return
        end
    end
end

function Vim:createMode(mode, enter, exit)
    if not self.modes[mode] then
        self.modes[mode] = { commands = { }, buffs = { }, onEnter = enter, onExit = exit }
    end
end

function Vim:buf(mode, cmd, action, ...)
    self:createMode(mode)

    table.insert(self.modes[mode].buffs, { cmd = cmd, action = action, args = { ... } })
end

function Vim:cmd(mode, cmd, action, ...)
    self:createMode(mode)

    table.insert(self.modes[mode].commands, { cmd = cmd, action = action, args = { ... } })
end
