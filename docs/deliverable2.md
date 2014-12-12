Mike McGinty, Deliverable 1
===========================


Completion Status
-----------------

Promised:

1. Figure out why read-json call is hanging
2. Figure out why it doesn't work with the simulator
3. Documentation
4. Raspberry Pi

Delivered:

1. (read-json) doesn't hang except when working with test data, specifically when using pipeviewer. No need to fix. Probably related to how pipeviewer does rate-limiting.
2. Simulator was making two connections for some silly reason. Fixed. (The fix also means it'll "just work" when flying multiple times.)
3. Much more documentation added, nearly everything is commented nicely now.
4. Raspberry Pi - Worked once, didn't test much with though. Little progress.

Added:

5. Added on-close code to the window frame, so that when closing the display it also shuts down the tcp listeners nicely. Still need to make it more friendly.


Code
----

The code can be found [on github](https://github.com/mach327/DCS-RWR-racket).

To replay test data (requires typical linux command line tools such as pipeviewer and netcat):

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

* tews2.jsonconn and tews5.jsonconn represent captured data from the simulator, meant to be replayed to our program for testing purposes (netcat works well for this).
* tews2.jsonconn has a format racket's JSON library cannot handle, but I've since corrected the simulator output and recaptured the same source that generated tews2 as tews5.
* ref/ has reference files, to aid in accuracy when coding the display.  
	If you read anything in here, start with README.md in the git, and then symbology.txt in ref/
* images/ has various images as necessary for creating presentations.
* docs/ has documents (such as these deliverables files)
