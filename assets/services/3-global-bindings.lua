mrequire "classes/actor"
mrequire "classes/room"

vim:buf("normal", "^q$",    function() os.exit() end)
vim:cmd("global", "l|oad",  Room.change)
vim:cmd("global", "q|uit",  os.exit)
vim:cmd("global", "give",   function(id) Actor.getActor("santino"):giveItem(id) end)

vim:cmd("global", "gamesave",   function(slot)
    SaveManager.save(slot, "")
end)

vim:cmd("global", "gameload",   function(slot)
    SaveManager.load(slot)
end)
