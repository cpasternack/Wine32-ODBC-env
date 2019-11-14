#!/usr/bin/env bash
#download latest winetricks (distribution might have old winetricks, with broken links
WGETV=`which wget`
if [ -z "$WGETV" ]
then
	winetricks  --self-update
else
	if [ -z "${HOME}/bin" ]
	then
		mkdir ${HOME}/bin
    #just grab the newest, store it in users local bin/
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    chmod +x winetricks
	fi
	./winetricks ${HOME}/bin
	#ln -s ${HOME}/bin /usr/local/bin/winetricks
fi
