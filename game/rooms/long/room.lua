room = {
    scene = {
        actors.gomez, actors.shaggy, actors.bouncer
    },
    events = {}
}


function room.on_load()
    print("loaded test2")
    
    register_hotspot(17, "door", "Door");
    register_door("door", "outside", 51, 8)
    register_hotspot(34, "window", "Window");
    register_hotspot(51, "drain", "Drain Pipe");
    register_door("drain", "outside", 17, 3)
    register_hotspot(68, "sign", "Sign");
    register_hotspot(85, "rear", "Back Alley");
    register_hotspot(102, "ladder", "Ladder");
    register_hotspot(119, "rope", "Rope");
end