conversation = {
    topic = nil,
    options = {}
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
 
tree = {
    {
        label = "Hello there!",
        action = function()
            print(">Why good day to yourself, sir.")
        end
    },
    {
        cond = statecond.not_mad,
        label = "What's good, b?",
        action = function()
            state.mad = true
            print(">You callin' me a potted plant!?")
            open_topic(tree2)
        end
    },
    {
        cond = statecond.mad,
        label = "Not to say you're a potted plant",
        action = function()
            print(">Good. You'd better not be.")
        end
    },
    {
        label = "Well bye",
        action = function()
            end_conversation()
        end
    },
   
    _load = function()
        print(">Yo what's good?!")
    end
}
 
tree2 = {
    {
        silent = true,
        label = "Yes",
        action = function()
           print("*gulp* No sir.");
           print(">Wise answer, boy.")
           open_topic(tree)
        end
    },
    {
        label = "No",
        action = function()
            print(">THAT'S WHAT I THOUGHT");
            open_topic(tree)
        end
    }
}
 
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
                print(select[opt].label)
            end
           
            select[opt].action()
        end
        print()
    end
end
 
function conversation.continue(opt)
    coroutine.resume(conversation.continue_routine, opt)
end
 
conversation.continue_routine = coroutine.create(conversation.continuer)