-- this should be better organized into files too

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
