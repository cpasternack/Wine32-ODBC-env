#!/usr/bin/env bash

#
# 
#

set -e

# download latest winetricks (distribution might have old winetricks, with broken links)

WGETV=`which wget`
# if wget isn't installed, try self update
if [ -z "${WGETV}" ]
then
	winetricks  --self-update
else
	if [ -d "${HOME}/bin" ]
	then
    cd ${HOME}/bin
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    chmod +x winetricks
  else
		mkdir ${HOME}/bin && cd ${HOME}/bin
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    chmod +x winetricks
  fi
fi
exit $?
