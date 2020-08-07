all:
	zip -9 -x bin/* -r shooter.love .
	mv -f shooter.love bin
	love /home/lazi/Documents/Games/ScrollingShooter