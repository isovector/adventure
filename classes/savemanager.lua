mrequire "classes/class"
mrequire "classes/actor"
mrequire "classes/scaffoldtable"
require "classes/lib/persistence"

local persistence = _G["classes/lib/persistence"]

--------------------------------------------------

local gamedata = { }

--------------------------------------------------

newclass("SaveManager", false)

SaveManager.version = "adventure engine v1.1"
SaveManager.format = 2

--------------------------------------------------

function SaveManager.install()
    gamedata = { }
    _G.save = gamedata
end

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
    
    gamedata[".meta"] = meta

    MOAIFileSystem.affirmPath(".saves/")
    persistence.store(string.format(".saves/%d.sav", slot), gamedata)
end

function SaveManager.load(slot)
    gamedata = persistence.load(string.format(".saves/%d.sav", slot))
    
    local meta = gamedata[".meta"]
    
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
    
    gamedata[".meta"] = nil
    _G.save = gamedata
    
    room:reload()
end
