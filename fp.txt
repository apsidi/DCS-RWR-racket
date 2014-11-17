http://www.tripod3d.com/brian/F15C%20Mission%208%20AAR/ScreenShot_023.jpg
http://youtu.be/KQ-ekHiVwsw

My final project idea is three 'parts', and I'll be doing it one way or
another - whether I do it for this class or not is what decides whether
I use Racket, python, a web-app, or something else for the client sides.

Some context: I want to work on or around a well-known and very popular
flight simulator (DCS World if you're interested). One of the major
benefits of this simulator is the ability to interact with it through
a lua API.  

I want a TEWS/RWR display (essentially a display of what
radar sources are radiating and being detected by an aircraft). The
simulator doesn't allow for easy exporting of the actual display to a
separate monitor, but the data can be exported relatively easily.

Each simulation frame or so:
{ 'Mode':0.000000, 'Emitters':[ 
	{ 'ID':'16778240', 'Power':0.789741, 'Azimuth':0.002113, 'Priority':160.789734, 'SignalType':'scan', 'Type':'mig-29' },
	{ 'ID':'16777984', 'Power':0.794159, 'Azimuth':0.043698, 'Priority':260.792358, 'SignalType':'lock', 'Type':'mig-29' },
	{ 'ID':'16777728', 'Power':0.788800, 'Azimuth':0.050152, 'Priority':160.788803, 'SignalType':'scan', 'Type':'mig-29' },
	{ 'ID':'16777472', 'Power':0.793666, 'Azimuth':0.090942, 'Priority':260.791870, 'SignalType':'lock', 'Type':'mig-29' }] 
	}
	Four mig-29s (or planes with similar radars), two locked onto me, two scanning.



I need to:
1. Export real-time object data from the simulator. I need:
  A. Received radar threats from TEWS. (Done, as of last night)
  B. All friendly force positions. (Somewhat done, last night - there's
  also some prior work I can peek at).
  C. Fuel, weapons, etc status for the players aircraft. (Done by
  someone else that I can adapt and use).

2. Display the RWR 
If I use racket, the RWR display will be on the rasperry pi I have,
which will be attached to a small (4"x3") LCD screen of a roughly appropriate
size. If I don't use racket, I'll do the same thing in python I'm more
familiar with it.
I would need to parse JSON from a network socket, and then display
graphically as appropriate.
Otherwise, I could make an android client and see if I can hack it on an old
Nook ereader I have lying around. That might be fun anyway.

3. Display a moving map of friendly object positions, and possibly
engagement range estimations. 
I will probably do this with a web-app - I have a small portion of this
done already, actually.


