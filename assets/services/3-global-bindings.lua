require "classes/actor"
require "classes/room"

vim:buf("normal", "^q$",    function() os.exit() end)
vim:cmd("global", "l|oad",  Room.change)
vim:cmd("global", "q|uit",  os.exit)
vim:cmd("global", "give",   function(id) Actor.getActor("santino"):giveItem(id) end)
