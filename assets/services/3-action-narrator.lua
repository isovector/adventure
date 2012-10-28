require "classes/game"
require "classes/narrator"

local nar = Narrator.new("", "...")

--------------------------------------------------

game.export("getNarration", function(conds) return nar:getString(conds) end)

--------------------------------------------------
-- default
nar:addRule("{object}", { "object" })

--------------------------------------------------
-- generic items
nar:addRule("Use {item} on {object}", { "item" })
nar:addRule("Show {item} to {object}", { "item", type = "Actor", "convo-piece" })

--------------------------------------------------
-- talk
nar:addRule("Talk to {object}", { verb = "talk", type = "Actor" })
nar:addRule("Use mouth on {object}", { verb = "talk" })

--------------------------------------------------
-- look
nar:addRule("Look at {object}", { verb = "look" })

--------------------------------------------------
-- touch
nar:addRule("Touch {object}", { verb = "touch" })
nar:addRule("Pick up {object}", { verb = "touch", "can-pick-up" })
nar:addRule("Push {object}", { verb = "touch", "can-push" })
nar:addRule("Pull {object}", { verb = "touch", "can-pull" })

--------------------------------------------------
-- game specific
