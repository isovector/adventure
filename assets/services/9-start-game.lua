import player, config, actors from Adventure

config = require "assets/config"

player = actors[config.player]
Room.getRoom(config.initialRoom):load()
