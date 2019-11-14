#!/usr/bin/env bash

#
#

#

#

#load odbc data sources from registry file:
if [ ! -z $REGFILE32 ] 
then
	wine regedit "$REGFILE32"
else
	exit 1
fi
exit 0
