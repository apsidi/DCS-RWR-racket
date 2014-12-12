DATA
====

All the files that end with `.jsonconn` are recorded data from the simulator output.
They are plain text files, where each line is a JSON object to be parsed.

You can replay these files to the RWR program (assuming it is already running with a `racket -r TEWS.rkt` invocation), like below:

	```
	cat rwr_demo.jsonconn | pv -l -L 10 |nc localhost 6001
	```

Some important things: 
* `cat` reads the file. the '|' (pipe) characters take the [output of one command and provide it as input to the next command.](http://linuxcommand.org/lts0060.php). 
* `pv` is the 'pipeviewer' program, "A terminal-based tool for monitoring the progress of data through a pipeline." You should be able to find it on most linux distributions. The arguments to pv provide line based (-l) rate limiting (-L) of 10 lines per second.
* `nc` is the 'netcat' program, a "network piping application" also known as the "swiss army knife of tcp". In this case it is taking it's STDIN and piping it to a TCP connection it initiates to localhost on TCP port 6001. 

If you'd like to test specific things, such as the blinking rwr-tracking symbology, you can use grep in the pipeline like this:

	```
	cat rwr_demo.jsonconn | grep lock | pv -l -L 10 |nc localhost 6001
	```

This means that online lines with the word 'lock' will be shown. You can also get fancier and use the full regex capabilities of grep with `-P`, search case-insensitively with `-i` or invert the search with `-v`. Obviously the man page of each of these command should be your first stop with any questions:

	```
	man cat
	man grep
	man pv
	man nc
	```


