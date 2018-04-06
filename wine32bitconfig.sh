#!/bin/bash

echo -e "Installing application wineprefix"

WINE32DIR_SYSTEM="/var/lib/wine32"
WINE32DIR_USER="~/.wine32"
WINEPREFIX="$WINE32DIR_SYSTEM/ODBC_ENV" 
WINEARCH="win32"
WINEDLLOVERRIDES="odbccp32=n,b;odbc32=n,b;oleaut32=n,b;msjet40=n,b"
REGFILE="./ODBC_DSN.reg"
REGFILEDLL="./OVERRIDE.reg"

if [ ! -z "$#" ]
then
	REGFILE=$1
	REGFILEDLL=$2

else
	echo -e "Usage: wine32bitconfig.sh [ODBC_DSN.reg] [OVERRIDE.reg]\n"
	echo -e "\tConfigures a wine32 prefix with ODBC DSNs specified in file"
	
fi
if [ ! -z "$WINEPREFIX/`echo $USER`" ]
then
	"$WINEPREFIX/`echo $USER`_ODBC32" $WINEARCH wine wineboot
	winetricks corefonts eufonts lucida opensymbol tahoma cjkfonts
	winetricks vb6run
	winetricks mdac28
	winetricks msxml4 mfc42 jet40 native_oleaut32
else
	"$WINEPREFIX/`echo $USER`" "$WINEARCH" wine wineboot
	winetricks corefonts eufonts lucida opensymbol tahoma cjkfonts
	winetricks vb6run
	winetricks mdac28
	winetricks msxml4 mfc42 jet40 native_oleaut32
fi

#load odbc data sources from registry file:
if [ ! -z $REGFILE ] 
then
	wine regedit "$REGFILE"
	wine regedit "$REGFILEDLL"
else
	exit(1)
fi

