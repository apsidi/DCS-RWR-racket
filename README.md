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
The racket magic is in TEWS.rkt
It can be run with

	$ racket -r TEWS.rkt

This starts the program, and a TCP listener on port 6001. 

Files
-----

* `README.md` and `README.txt` (.txt is a symlink to .md) -- This file.
* `TEWS.rkt`    -- The file that contains the main loop, and includes the other .rkt files.
* `classes.rkt` -- The file that contains the `threat%` and `rwr%` classes, and the two main drawing functions, `(draw-threats)`, and `(draw-threatscope)`. 
* `conf.rkt     -- The file with basic configuration options (such as what TCP port to listen on).
* `paths.rkt    -- The file that contains the drawing paths.
* `threats.rkt	-- The file that contains threat definitions and related functions.
* `data/`	-- The directory that has test data. See the `README.md` in `data/` for more info.
  * `README.md`	-- the readme for `data/`, includes instructions on replaying data to our racket TEWS.
  * `rwr_demo.jsonconn`	-- The rwr_demo data, meant to be used for demo purposes. Purposefully includes a large variety of situations to show off the program. See *Videos*, below.
  * `tews5.jsonconn`	-- This data is associated with the first video that was used for the class project.
  * `varied.jsonconn`	-- No video is associated with this, but it shows a large variety of radar emitters.
  * `clean_sweep.jsonconn`	-- This data comes from a (rather poor) playthrough of the "clean sweep" F-15C mission.
* `docs/`	-- The directory that has documentation, either for the project or the github in general.
  * `mike_mcginty_fpp.pdf`	-- Mike's project proposal pdf.
  * `deliverable1.{md,pdf}`	-- Mike's first deliverable in markdown and its PDF output.
  * `deliverable2.{md,pdf}`	-- Mike's second deliverable in markdown and its PDF output.
  * `rpi/`	-- Has files associated with the Raspberry Pi
    * `install.archlinux.md`	-- The installation guide for the RPi, assuming ArchLinuxARM
* `ref/`	-- This directory contains various reference data from the simulator.
  * `types.txt` -- This is a quick summary and reference for how DCS does its unit type system.
  * `fp.txt` 	-- An early set of notes Mike wrote when deciding to do this project.
  * `symbology.txt`	-- Has some summarized notes from the next two files on how the RWR works.
  * `DCS_Document_Pack1308.zip`	-- A zip of PDFs describing various aspects of the A-10C RWR. Source: http://www.digitalcombatsimulator.com/en/files/86362/
  * `F-15C DCS Flaming Cliffs Flight Manual EN.pdf`	-- The PDF manual for DCS F-15C. Source: DCS software.
  * `RWR-E2.png`	-- I got this from http://wiki.hoggit.us/view/RWR, and used it as a reference when creating our symbol paths in `paths.rkt`

Classes
-------

The rwr% class, when instantiated, is an object that represents an RWR display.
A threat% object represents a radar emitter detected by the TEWS system.


DCS World
--------
Exports data every .1s.
lua file must currently be edited to include hostname or ip address of
machine running this racket code.

Example line, pretty printed and commented with "#" lines:

	{ "Mode":0.000000, #the mode of the RWR system. "0" is show all, "1" is show only locks
	"MTime": 8.800000, # The model time of the simulator. A time delta in seconds from the start of the simulation.
	"Emitters":[  #a list of detected radar emitters
		{ "ID":"16777472",  #DCS Worlds entity id
			"Power":0.183416,  #the received signal strength of the radar emission
			"Azimuth":1.909694, #azimuth, radians
			"Priority":130.183411,  #priority - see the reference documents for an example.
			"SignalType":"scan",  #can be scan, lock, etc - see reference documents
			"Type":"TAKR Kuznetsov",  #the "type" of object that owns the radar as reported based on the lookup of typeints with the simulator
			"TypeInts":[3.000000,12.000000,12.000000,1.000000]  #the different levels of types - for instance, level1 (the first int), means airborne (1), land(2), ship(3), etc
			},
		{ "ID":"16778240", 
			"Power":0.251832, 
			"Azimuth":-0.261467,
			"Priority":160.251831, 
			"SignalType":"scan", 
			"Type":"mig-29c",
			"TypeInts":[1.000000,1.000000,1.000000,50.000000] 
			},
		{ "ID":"16781568", 
			"Power":0.399237, 
			"Azimuth":-2.257212, 
			"Priority":160.399231, 
			"SignalType":"scan", 
			"Type":"F-15C", 
			"TypeInts":[1.000000,1.000000,1.000000,6.000000] 
			},
		{ "ID":"16778496", 
			"Power":0.718432, 
			"Azimuth":-1.715873, 
			"Priority":110.718430, 
			"SignalType":"scan", 
			"Type":"a-50", 
			"TypeInts":[1.000000,1.000000,5.000000,26.000000] 
			}
		] 
	}

Azimuth, from the [DCS Wiki](http://en.wiki.eagle.ru/wiki/Simulator_Scripting_Engine/DCS:_World_1.2.1/Part_1):

	Angle = number
	Angle is given in radians.
	Azimuth = Angle
	Azimuth is an angle of rotation around world axis y counter-clockwise. 

However, this is for 'absolute's, those values relative to the world.
When reading azimuth in relation to a specific airplane (such as our
TEWS interpretation), the 0 value extends out the nose of the airplane -
negative values off to the left (counter clockwise), positive values
clockwise looking down on top of the plane. This is NOT obvious from
the DCS documentation, but was confirmed by looking at the rendered
TEWS display in-game and comparing that view with the exported data at
that time. [See the in-game video](https://www.youtube.com/watch?v=-IDGZ51gnpg&list=UUmEVA0u2gL-og0NJ_SP6hiw) 
and compare it to the data in tews5.jsonconn to verify this for yourself.



Test Data
=========

One can use the \*.jsonconn files as testdata in the following fashion:

	$ cat tews5.jsonconn |pv -l -L 10 | nc localhost 6001

The above line will take the tews5 data, printing at 10 (-L) lines (-l)
per second, and give that input to netcat, which will connect to the local
computer on port 6001 to connect tou the listening racket (which must already
be running). See the readme in `data/` for more info and the test data files themselves.


Videos
======

There are four related videos meant to be used with the `rwr_demo.jsonconn` test data.
I've uploaded them to youtube for ease of use, these are the URLs:
	
* [rwr_demo](http://youtu.be/7T8lflEjdZY)
* [rwr_demo_outsideview](http://youtu.be/EsSbAvZ5rNQ)
* [rwr_demo_outsideview_static](http://youtu.be/5JH7kezZhyg)
* [rwr_demo_rwrdisplay](http://youtu.be/RGiRabwXg6M)

I also have the raw video available, just ask. With a fast enough
computer, the videos can be played in sync with VLC's input slave
like this:

	$ vlc rwr_demo.ogv --input-slave=rwr_demo_outsideview.ogv#rwr_demo_outsideview_static.ogv#rwr_demo_rwrdisplay.ogv



