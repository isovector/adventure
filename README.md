Running on Linux
================

Make sure you install the prerequisites before attempting to compile on linux:

* lua 5.1.4
* luarocks
* metalua 0.5
* sdl 1.2
* sdl_gfx 2.0
* sdl_image 1.2
* sdl_ttf 2.0
* imagemagick 6.7.6.0 (for compile-time image building)
* synfig 0.63.04 (for compile-time image building)

Then ensure you have lfs installed:

> $ luarocks download luafilesystem

> $ luarocks install luafilesystem

Next clone the repository

> $ git clone git://github.com/Paamayim/adventure.git

> $ cd adventure

Now you can attempt to build 

> $ make

With luck, the host has been compiled and can be run as

> $ ./adventure



Running on Windows
==================

Download the [win32 binary package and script files](https://github.com/Paamayim/adventure/downloads).

Unzip the scripts, and then unzip the binary package into the same directory. 
Now running adventure.exe should (hopefully) initialize the game.

*WARNING* This is probably broken on 32-bit until I find a nice way to build multi-architecture luac files.



Debugging with SciTE
====================
To enable debugging integration with SciTE, add the following to your SciTE user properties:

```
adventure.path=/path/to/adventure
ext.lua.startup.script=$(adventure.path)/utils/scite.lua
ext.lua.auto.reload=1
```

This will allow you to set breakpoints with F9.
