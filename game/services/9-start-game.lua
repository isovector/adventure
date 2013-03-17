import player, config, actors from Adventure

config = require "game/config"

player = actors[config.player]
Room.getRoom(config.initialRoom):load()
