actors = {
    jack = {
        id = "jack",
        name = "Gomez",
        ignore_ui = true,
        pos = {x = 600, y = 300}, 
        color = 255, 
        speed = 150, 
        goal = nil, 
        goals = {},
        inventory = {},
        flipped = false,
        aplay = animation.start(animations.gomez, "stand")
    }
}
player = actors.jack


items = {
    beer = {
        label = "Cheap Beer",
        image = get_bitmap("resources/items/beer.pcx")
    }
}

item_events = {}

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

function item_events.beer_look()
    say("Jack", "A fine bottle of beer")
end

function item_events.beer_talk()
    say("Jack", "Don't mind if I do!")
    player.inventory["beer"] = nil
end

function item_events.beer_touch()
    say("Jack", "No response...")
end

function jack_talk() 
    conversation.say("This is not warcraft in space", player.pos.x, player.pos.y - 120, player.color)
end