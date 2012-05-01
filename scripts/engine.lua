engine = {
    fps = 0,
    allow_input = true,
    state = "game",
    
    events = {
        draw = event.create()
    }
}

events.game = {
    tick = event.create()
}

events.console = {
    input = event.create()
}
