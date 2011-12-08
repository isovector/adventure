Running on Linux
================

Make sure you install the prerequisites before attempting to compile on linux:

* allegro4 4.4.2
* lua 5.1.4
* luarocks

Then ensure you have lfs installed:

> $ luarocks download luafilesystem
> $ luarocks install luafilesystem

Next clone the repository

> $ git clone git://github.com/Paamayim/adventure.git
> $ cd adventure

Now you can attempt to build 

> $ gcc `allegro-config --libs` -lm -llua -std=c99 -o adventure *.c

With luck, the host has been compiled and can be run as

> $ ./adventure



Running on Windows
==================

Download the [win32 binary package] [bin], and the [source zipball] [zip].

    [bin]: https://github.com/Paamayim/adventure/downloads
    [zip]: https://github.com/Paamayim/adventure/zipball/master
    
Unzip the zipball, and then unzip the binary package into the same directory. 
Now running adventure.exe should (hopefully) initialize the game.