local item = items.create("beer", "Cheap Beer", "game/items/beer/beer.pcx")

item.events.look.sub(function()
    player.say("A fine bottle of beer")
end)

item.events.talk.sub(function()
    player.say("Don't mind if I do!")
    player.inventory["beer"] = nil
end)
