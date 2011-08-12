test2 = {}

print("TEST ROOM LOADED SUCCESSFULLY");

register_hotspot(17, "tub", "Tub");
register_hotspot(34, "plant", "Potted Plant");
register_hotspot(51, "towel", "Towel");
register_hotspot(68, "light", "Facet");
register_hotspot(85, "light", "Perfumes");
register_hotspot(102, "light", "Plumbing");
register_hotspot(119, "light", "Rose Petal");
print("registered all hotspots")

function test2.plant_talk()
    open_topic(tree)
end

function test2.towel_touch()
    give_item(player, "beer")
    say("Jack", "I found a beer under this towel. Somehow.")
end

function test2.tub_beer()
    remove_item(player, "beer")
    say("Jack", "That's a good place to put my beer!");
end

function test2.table_talk()
    say("Jack", "Hello?");
    say("Table", "What do you want!?");
    say("Jack", "Yikes!");
end

function test2.table_touch()
    say("Jack", "I can't fit that into my pants!");
end

function test2.art_click()
    walk(actors.paul, 600, 550)
end