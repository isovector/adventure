adventure engine 1.0.0
======================

adventure engine is a MOAI-based game engine for creating old '90s styled LucasArts graphical point-n-click adventure games. The engine is open-source, and permissively licensed, so that your games can be sold with no licensing hassles. adventure engine has most of the features you'd expect from a neo-classic adventure game including support for actors, dialogue, inventories, multiple verbs and by being written in lua - it seemlessly includes an expressive scripting language. In addition, it comes with a fully functional content editor and an art pipeline.

The codebase is broken into two main directories, *classes/* and *assets/*. The former is for most of the genre-related, game-agnostic code: pathfinding, room loading, inventory management, etc. The latter directory contains all of the game-related portions of the game: individual characters, locations, conversations and interface, among other things.

Art assets can be created in synfig-studio, and imported into the game via the makefile. The wikipage on Costumes has more information.

Unfortunately, at this time there is little documentation of the engine as a whole, or of any individual components. The room editor interface is notoriously bad, but those familiar with vim might have a fair go at getting it to work. See the exported commands at the end of *assets/sheets/editor.lua* for breadcrumbs on where to start. That being said, if you have any questions, feel free to contact me and I will do my best to respond in a timely fashion.

Happy adventuring!



Running on Linux
================

Make sure you install the prerequisites before attempting to compile on linux:

* lua 5.1.4
* metalua 0.4.1 RC1
* imagemagick 6.7.6.0 (for compile-time image building)
* synfig 0.63.04 (for compile-time image building)

> $ git clone git://github.com/Paamayim/adventure.git && git clone git://github.com/Paamayim/moai-dev.git && cd moai-dev && cd cmake && cmake . && make && cp src/hosts/moai-untz ../../adventure && cd ../../adventure

That should have build everything and if you're lucky you're good to go! Now you can start adventure via:

> $ ./adventure



Running on Windows
==================

Clone the adventure source

Install http://getmoai.com/moai-sdk.html, and track down a metalua distributable. I don't have a windows box, and so I am unable to guide you much further than this. That being said, the code is platform agnostic and I will bet dollars to donuts that any difficulties you might experience will be with MOAI or metalua.

After all of that, try:

> adventure.bat

Easy.
