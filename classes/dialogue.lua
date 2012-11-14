require "classes/class"
require "classes/task"

newclass("Topic",
    function(id)
        return {
            id = id,
            options = { }
        }
    end
)

function Topic:addOptions(...)
    for _, opt in ipairs({ ... }) do
        if opt.enabled == nil then
            opt.enabled = true
        end
        
        opt.flags = opt.flags or ""
        
        table.insert(self.options, opt)
    end
end

function Topic:getOptions()
    local ret = { }

    for id, opt in ipairs(self.options) do
        if opt.enabled and (not opt.condition or opt.condition()) then
            table.insert(ret, { id = id, caption = opt.caption })
        end
    end
    
    return ret
end

function Topic:option(id)
    local option = self.options[id]
    
    if option.flags:match("o") then
        option.enabled = false
    end
    
    Task.start(function()
        game.enableInput(false)
    
        if not option.flags:match("s") then
            -- TODO(sandy): make this use the player
            Actor.getActor("santino"):say(option.caption)
        end

        option.callback()
        
        game.enableInput(true)
        
        if not option.flags:match("x") then
            self:show()
        end
    end)
end

function Topic:show()
    game.showTopic(self)
end

--------------------------------------------------

newclass("Dialogue",
    function()
        return {
            topics = { }
        }
    end
)

function Dialogue.time(msg)
    local words = 0
    for _ in msg:gfind("[^%s]+") do words = words + 1 end
    
    words = math.max(5, words)
    return words * 0.5
end

function Dialogue:addTopic(id)
    local topic = Topic.new(id)
    self.topics[i] = topic
    return topic
end
