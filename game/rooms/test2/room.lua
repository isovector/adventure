room = {
    scene = {
        actors.gomez
    }
}

function room.on_init()
    debug.log(debug.ROOM, "initialized room2")
end

function room.on_load()
    debug.log(debug.ROOM, "loaded room2")

    register_hotspot(17, "tub", "Tub");
    register_hotspot(34, "plant", "Potted Plant");
    register_hotspot(51, "towel", "Towel");
    register_hotspot(68, "light", "Facet");
    register_hotspot(85, "perfume", "Perfumes");
    register_hotspot(102, "light", "Plumbing");
    register_hotspot(119, "light", "Rose Petal");
end

function room.perfume_touch()
    switch_room("test1", 1)
end

function room.plant_talk()
    open_topic(tree)
end

function room.towel_touch()
    give_item(player, "beer")
    enable_path(17, true)
    say(player, "I found a beer under this towel. Somehow.")
end

function room.tub_beer()
    remove_item(player, "beer")
    say(player, "That's a good place to put my beer!");
end

function room.table_talk()
    say(player, "Hello?");
    say("Table", "What do you want!?");
    say(player, "Yikes!");
end

function room.table_touch()
    say(player, "I can't fit that into my pants!");
end

function room.art_click()
    walk(actors.paul, 600, 550)
end