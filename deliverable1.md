Mike McGinty, Deliverable 1
===========================


Completion Status
-----------------

Promised:

1. Gather more resources
2. Figure out why read-json call is hanging
3. Classify radar types
4. Lookup table for proper symbology
5. Fix coordinate differences between simulator and racket draw

Delivered:

1. More resources gathered
2. read-json call still hangs, not clear why. Will possibly parse strings as appropriate from network stream ourselves and pass to string->json function. Also returns #eof from the actual simulator for some reason, on same data! Not at all clear why, but possibly related to first problem?
3. (To clarify, determine if something is airborne, awacs, tracking, etc). Relevant radar types classified.
4. Lookup table started, but incomplete. A complete table would be...quite large. We're looking into a slicker way of doing it, such as querying the simulator directly or dumping the simulator's internal database.
5. Fixed! Coordinate systems now align properly.


Code
----

The code can be found [on github](https://github.com/mach327/DCS-RWR-racket).

To examine (requires typical linux command line tools such as pipeviewer and netcat):

	$ racket -r TEWS.rkt

and

	$ cat tews5.jsonconn | nc localhost 6001  # This will run at a very high speed, you can try the next line instead for a more realistic playback
	$ cat tews5.jsonconn | pv -l -L 10 |nc localhost 6001


Code Index
----------

* "TEWS.rkt"    : has main loop and some minor functions that might not be in use at this time.
* "conf.rkt"    : exists to hold minor configurations, tcp listen port, fonts, etc
* "classes.rkt" : contains classes, e.g. threat%, rwr%, and functions draw-threats and draw-threatscope.
* "threats.rkt" : contains threat definitions and helper functions (e.g. threat string lookup table).
* "paths.rkt"   : should only contain drawing path definitions.

Other File Index
-----------------

tews2.jsonconn and tews5.jsonconn represent captured data from the simulator, meant to be replayed to our program for testing purposes (netcat works well for this).
tews2.jsonconn has a format racket's JSON library cannot handle, but I've since corrected the simulator output and recaptured the same source that generated tews2 as tews5.
ref/ has reference files, to aid in accuracy when coding the display.
	If you read anything in here, start with README.md in the git, and then symbology.txt in ref/
images/ has various images as necessary for creating presentations.
