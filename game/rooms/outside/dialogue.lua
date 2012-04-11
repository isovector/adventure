local room = rooms.outside
local bouncer = actors.bouncer

room.dialogue = {
    bouncer = {
        {
            label = "Can I get in there?",
            once = true,
            action = function()
                state.asked = true
                bouncer:say("No. You can't.")
            end
        },
        {
            label = "Why can't I enter?",
            cond = statecond.asked,
            once = true,
            action = function()
                bouncer:say("Because I said so.")
                player:say("That doesn't sound like a very good reason")
                bouncer:say("Because I said so AND I have all of the authority")
            end
        },
        {
            label = "Is there some way I could convince you?",
            action = function()
                bouncer:say("What did you have in mind?")
                open_topic(room.dialogue.bouncer2)
            end
        },
        {
            label = "I'll be taking off now",
            action = function()
                bouncer:say("Run along now")
                end_conversation()
            end
        },
        _load = function()
            player:say("Hullo there!")
            bouncer:say("Whaddya want?")
        end
    },
    
    bouncer2 = {
        {
            label = "I was hoping it was the thought that counted",
            once = true,
            action = function()
                bouncer:say("It's not. But nice try.")
            end
        },
        {
            label = "How about A BRAND NEW CAR?",
            once = true,
            action = function()
                bouncer:say("I already got one of those")
                player:say("Really?")
                bouncer:say("No, but you don't really have one either.")
                player:say("Touche")
            end
        },
        {
            label = "Money?",
            once = true,
            action = function()
                bouncer:say("How much you got?")
                player:say("Oh... about $0")
                bouncer:say("Yeah right.")
            end
        },
        {
            label = "A personal favor?",
            action = function()
                bouncer:say("Well I *am* a little thirsty...")
            end
        },
        {
            label = "I'll get back to you when I think of something",
            action = function()
                bouncer:say("I'll be here.")
                open_topic(room.dialogue.bouncer)
            end
        },
        _load = function()
        end
    }
}
