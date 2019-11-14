#!/usr/bin/env bash


#load odbc data sources from registry file:
if [ ! -z $REGFILE64 ] 
then
	wine regedit "$REGFILE64"
else
	exit 1
fi
exit 0
