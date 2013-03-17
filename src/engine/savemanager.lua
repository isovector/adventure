--- A static class to manage saving and loading.

mrequire "src/class"
mrequire "src/game/actor"
mrequire "src/engine/scaffoldtable"
require "src/lib/persistence"

local persistence = _G["src/lib/persistence"]

--------------------------------------------------

import save, room from Adventure
save = { }

--------------------------------------------------

--- The static SaveManager class.
-- @newclass SaveManager
newclass("SaveManager", false)

--- The human-friendly version of save games.
SaveManager.version = "adventure engine v1.1"

--- The actual format version of save games.
-- This number must align between then serializer and deserializer for save games to work.
SaveManager.format = 2

--------------------------------------------------

--- Internal class to register saving functionality.
-- This is usually called by the 0-save-games.lua service.
function SaveManager.install()
    save = { }
end

--- Saves the current state of the game into a slot.
-- @param slot The save game slot. 0 is autosave.
-- @param name The human readable name of the save game. This is provided by the user.
function SaveManager.save(slot, name)
    local meta = { }
    meta.room = room.id
    meta.format = SaveManager.format
    meta.version = SaveManager.version
    
    meta.actors = { }

    for id, actor in pairs(Actors) do
        meta.actors[id] = { }
        local mactor = meta.actors[id]
        
        mactor.inventory = { }
        for id in pairs(actor.inventory) do
            table.insert(mactor.inventory, id)
        end
        
        if actor.prop then
            mactor.location = { actor:location() } 
        end
    end
    
    save[".meta"] = meta

    MOAIFileSystem.affirmPath(".saves/")
    persistence.store(string.format(".saves/%d.sav", slot), save)
end

--- Loads a save game into memory.
-- @param slot The save game slot to load
function SaveManager.load(slot)
    save = persistence.load(string.format(".saves/%d.sav", slot))
    
    local meta = save[".meta"]
    
    if meta.format ~= SaveManager.format then
        error("Unable to load incompatable format of save game")
    end
    
    Room.change(meta.room)
    
    for id, actordata in pairs(meta.actors) do
        local actor = Actor.getActor(id)
        for _, item in ipairs(actordata.inventory) do
            actor:giveItem(item)
        end
        
        local loc = actordata.location
        if loc then
            actor:joinScene()
            actor:teleport(loc[1], loc[2])
        end
    end
    
    save[".meta"] = nil
    
    room:reload()
end
