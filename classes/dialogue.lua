require "classes/class"

newclass("Topic",
    function(id)
        return {
            id = id,
            options = { }
        }
    end
)

function Topic:addOptions(options)
    for _, opt in ipairs(options) do
        table.insert(self.options, opt)
    end
end

function Topic:getOptions()
    local ret = { }

    for id, opt in ipairs(self.options) do
        if not opt.condition or opt.condition() then
            table.insert(ret, { id = id, caption = opt.caption })
        end
    end
    
    return ret
end

function Topic:option(id)
    
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
    
    words = math.max(8, words)
    return words * 0.9
end

function Dialogue:addTopic(id)
    local topic = Topic.new(id)
    self.topics[i] = topic
    return topic
end
