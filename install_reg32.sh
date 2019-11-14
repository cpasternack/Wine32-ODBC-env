#!/usr/bin/env bash

#
#

#
set -e
#

#load odbc data sources from registry file:
if [ ! -z "${REGFILE32}" ] 
then
	wine regedit "${REGFILE3}2"
else
	exit 1
fi
exit $?
