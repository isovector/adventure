Running on Linux
================

Make sure you install the prerequisites before attempting to compile on linux:

* lua 5.1.4
* imagemagick 6.7.6.0 (for compile-time image building)
* synfig 0.63.04 (for compile-time image building)

> $ git clone git://github.com/Paamayim/adventure.git && git clone git://github.com/Paamayim/moai-dev.git && cd moai-dev && mkdir build && cd build && cmake .. && make && cp src/hosts/gluthost ../../adventure && cd ../../adventure

That should have build everything and if you're lucky you're good to go! Now you can start adventure via:

> $ ./adventure



Running on Windows
==================

Clone the adventure source

Extract https://github.com/downloads/Paamayim/adventure/win32-moai-2012.09.17.zip to the same directory as adventure

> adventure.bat

Easy.