items.beer = {
        label = "Cheap Beer",
        image = get_bitmap("game/items/beer/beer.pcx")
}

function item_events.beer_look()
    say("Jack", "A fine bottle of beer")
end

function item_events.beer_talk()
    say("Jack", "Don't mind if I do!")
    player.inventory["beer"] = nil
end
