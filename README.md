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
The racket magic is in TEWS.rkt
It can be run with

	$ racket -r TEWS.rkt


DCS World
--------
Exports data every .1s.
lua file must currently be edited to include hostname or ip address of
machine running this racket code.

Example line, pretty printed and commented with "#" lines:

	{ 'Mode':0.000000, #the mode of the RWR system. "0" is show all, "1" is show only locks
	'MTime': 8.800000, # The model time of the simulator. A time delta in seconds from the start of the simulation.
	'Emitters':[  #a list of detected radar emitters
		{ 'ID':'16777472',  #DCS Worlds entity id
			'Power':0.183416,  #the received signal strength of the radar emission
			'Azimuth':1.909694, #azimuth, radians
			'Priority':130.183411,  #priority - see the reference documents for an example.
			'SignalType':'scan',  #can be scan, lock, etc - see reference documents
			'Type':'TAKR Kuznetsov',  #the 'type' of object that owns the radar as reported based on the lookup of typeints with the simulator
			'TypeInts':[3.000000,12.000000,12.000000,1.000000]  #the different levels of types - for instance, level1 (the first int), means airborne (1), land(2), ship(3), etc
			},
		{ 'ID':'16778240', 
			'Power':0.251832, 
			'Azimuth':-0.261467,
			'Priority':160.251831, 
			'SignalType':'scan', 
			'Type':'mig-29c',
			'TypeInts':[1.000000,1.000000,1.000000,50.000000] 
			},
		{ 'ID':'16781568', 
			'Power':0.399237, 
			'Azimuth':-2.257212, 
			'Priority':160.399231, 
			'SignalType':'scan', 
			'Type':'F-15C', 
			'TypeInts':[1.000000,1.000000,1.000000,6.000000] 
			},
		{ 'ID':'16778496', 
			'Power':0.718432, 
			'Azimuth':-1.715873, 
			'Priority':110.718430, 
			'SignalType':'scan', 
			'Type':'a-50', 
			'TypeInts':[1.000000,1.000000,5.000000,26.000000] 
			}
		] 
	}


Test Data
=========

One can use the \*.jsonconn files as testdata in the following fashion:

	$ cat tews5.jsonconn |pv -l -L 10 | nc -l -p 6000

The above line will take the tews5 data, printing at 10 (-L) lines (-l)
per second, and give that input to netcat, which will listen (-l) on port
(-p) 6000 for incoming tcp connections.
