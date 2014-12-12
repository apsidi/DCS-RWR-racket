Arch Linux Install Instructions
==============================

These will work for a Raspberry Pi running 
[Arch Linux ARM](http://archlinuxarm.org/), but are also a handy reference for most
any Systemd based Linux system. The package names are all based on the
Arch Linux Arm package names, which are usually the same as the official
Arch Linux packages.

1. Install your favorite linux. For the RPi, [Raspbian]() or [Arch
Linux ARM]() are excellent choices. For Raspbian, go to the [Downloads
Page](http://www.raspberrypi.org/downloads/#), and [follow the official
instructions](http://www.raspberrypi.org/documentation/installation/installing-images/README.md)
to get it installed. For Arch Linux ARM, the full set of instructions for
the RPi that include the download and SD card installation is available
[here](http://archlinuxarm.org/platforms/armv6/raspberry-pi).
2. Now that you have your basic linux system installed on your RPi,
make sure the Pi is connected to the internet, and that you either
have ssh access or a keyboard and display hooked up. For help with
this (and other things), I recommend you check [this Arch Wiki RPi
guide](https://wiki.archlinux.org/index.php/Raspberry_Pi) and [this
elinux.org guide](http://elinux.org/ArchLinux_Install_Guide).
3. So now you have console and internet access on the Pi. Upgrade the
whole system and install `racket`. This can take a long while because
of the limited resources of the Pi.

	```
	pacman -Syu racket
	```

4. Now, you need to [configure
autologin.](https://wiki.archlinux.org/index.php/automatic_login_to_virtual_console).
Follow the linked guide, and compare your results to what worked for me
(my user name is 'mike'):

	```
	[mike@alarmpi ~] $ cat /etc/systemd/system/getty\@tty1.service.d/autologin.conf 
	[Service]
	ExecStart=
	ExecStart=-/usr/bin/agetty --autologin mike --noclear %I 38400 linux
	Type=simple
	```

5. So now you have a user that automatically logs in. You can now edit
their `.bash_profile` so that they automatically startx on console
login. Edit the bottom of `.bash_profile`, adding this line:

	```
	[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
	```

6. The last part of getting this to work (if all is set up correctly) is
to install Xorg and edit your RPi user's .xinitrc file so that it starts
the racket program. You can find the Arch Linux guide for the RPi video
[on the wiki](https://wiki.archlinux.org/index.php/Raspberry_Pi#Video)
and the more general Arch Linux Xorg guide
[here](https://wiki.archlinux.org/index.php/xorg).
7. The last edit you need, assuming all is well with Xorg, is to modify
the .xinitrc file of the user you have logging in automatically. I
found it helpful to turn off power saving and screen blanking for X as
well. For program, I assume you have already cloned the repository down to
`~/DCS-RWR-racket` on your RPi.

	```
	[mike@alarmpi ~] $ cat .xinitrc 
	xset s off
	xset -dpms
	cd DCS-RWR-racket; racket -r TEWS.rkt
	```

That's it! It can take a while on a Raspberry Pi for the display to
show up, and it uses quite a bit of memory and CPU. I recommend turning
off every service you don't absolutely need on the RPi. If it runs
slow or stutters, it might be worthwhile to try setting the priority
of the racket process with the `nice` command, but I haven't yet. In
my testing, it worked pretty well with the actual simulator, and only
stumbled occasionaly when replaying data to it with netcat.
