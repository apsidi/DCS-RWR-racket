Intro
=====
This is a project in racket for drawing a Radar Warning Receiver (RWR)
display from data exported by DCS World's Flaming Cliffs 3 module,
specifically the F-15 model.

An RWR display shows a 2D top-down view of radar signals received by
the F-15's Tactical Electronic Warfare System (TEWS).

DCS World does not allow for the placement of the F-15's RWR display
on a second monitor like it does the radar MFD, so this project was
created to recreate the display based on exported data from the simulator
over a TCP socket, using a modified version of leonpo's [Android TEWS
display](http://forums.eagle.ru/showthread.php?t=100057) export.lua to
export the data.


Overview
========
Coming soon.

DCS World
--------
Export's data every .1s



Test Data
=========

One can use the *.jsonconn files as testdata in the following fashion:

	$ cat tews5.jsonconn |pv -l -L 10 | nc -l -p 6000

The above line will take the tews5 data, printing at 10 (-L) lines (-l)
per second, and give that input to netcat, which will listen (-l) on port
(-p) 6000 for incoming tcp connections.
