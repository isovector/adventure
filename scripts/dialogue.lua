conversation = {
    topic = nil,
    options = {},
    words = {}
}

state = { mad = false }
statecond = setmetatable({}, {
    __index = function(table, key)
        if key:sub(0, 4) == "not_" then
            table[key] = function()
                return not state[key:sub(5)]
            end
        else
            table[key] = function()
                return state[key]
            end
        end

        return table[key]
    end
})

function open_topic(topic)
    conversation.topic = topic
    if topic._load and not topic.loaded then
        topic._load()
        topic.loaded = true
    end

    if topic._enter then topic._enter() end
    coroutine.resume(conversation.continue_routine)
end

function end_conversation()
    conversation.topic = nil
end

function conversation.show(option)
    return not option.cond or option.cond()
end

function conversation.continuer()
    while true do
        if not conversation.topic then
            coroutine.yield("topic")
        end

        local select = {}
        for key, node in ipairs(conversation.topic) do
            if conversation.show(node) then
                table.insert(conversation.options, node.label)
                table.insert(select, node)
            end
        end

        local opt = coroutine.yield("option")
        conversation.options = {}
        if conversation.topic._options and conversation.topic._options.once then
            conversation.topic = nil
        end

        if  select[opt] then
            if not select[opt].silent then
                tasks.begin(function() say(player, select[opt].label) end, conversation.continue)
                coroutine.yield()
            end

            if select[opt].action then
                tasks.begin(select[opt].action, conversation.continue)
                coroutine.yield()
            end
        end
        print()
    end
end

function conversation.continue(opt)
    coroutine.resume(conversation.continue_routine, opt)
end

function conversation.say(message, x, y, color, duration)
    if not color then
        color = 0
    end

    if not duration then
        duration = #message * 0.075
    end

    msg = {
        message = message,
        color = color,
        x = x,
        y = y,
        duration = duration
    }

    table.insert(conversation.words, msg)

    return msg
end

function conversation.pump_words(elapsed)
    for key, val in ipairs(conversation.words) do
        val.duration = val.duration - elapsed

        if val.duration <= 0 then
            table.remove(conversation.words, key)
        end
    end
end

function say(actor, message)
    print(actor.name .. "> " .. message)
    msg = conversation.say(message, actor.pos.x, actor.pos.y - actor.aplay.set.height - 20, actor.color)
    wait(msg.duration * 1000)
end

conversation.continue_routine = coroutine.create(conversation.continuer)