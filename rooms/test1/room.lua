room = {
    scene = {
        player
    }
}

function room.on_init()
    print("initialized test1")
end

function room.on_load()
    print("loaded test2")
    
    register_hotspot(17, "tub", "Tub");
    register_hotspot(34, "plant", "Potted Plant");
    register_hotspot(51, "towel", "Towel");
    register_hotspot(68, "light", "Facet");
    register_hotspot(85, "perfume", "Perfumes");
    register_hotspot(102, "light", "Plumbing");
    register_hotspot(119, "light", "Rose Petal");
end

function room.perfume_touch()
    switch_room("test2", 1)
end

function room.plant_talk()
    open_topic(tree)
end

function room.towel_touch()
    give_item(player, "beer")
    say("Jack", "I found a beer under this towel. Somehow.")
end

function room.tub_beer()
    remove_item(player, "beer")
    say("Jack", "That's a good place to put my beer!");
end

function room.table_talk()
    say("Jack", "Hello?");
    say("Table", "What do you want!?");
    say("Jack", "Yikes!");
end

function room.table_touch()
    say("Jack", "I can't fit that into my pants!");
end

function room.art_click()
    walk(actors.paul, 600, 550)
end