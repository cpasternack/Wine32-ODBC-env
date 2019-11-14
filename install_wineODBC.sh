#!/usr/bin/env bash
set -e

export WINEDEBUG=-all

if [ ! -z "${WINEPREFIX}" ] || [ -z "${1}"  ]
then
	${WINEARCH} ${WINEPREFIX} wine wineboot
	winetricks -q corefonts eufonts lucida opensymbol tahoma cjkfonts
	winetricks -q vb6run
	winetricks -q mdac28
	winetricks -q msxml4 mfc42 jet40 native_oleaut32
else
  # set the variables, and create a new wineprefix
	WINEPREFIX="${USER}/wine32"
  WINEARCH="win32"
  ${WINEARCH} ${WINEPREFIX} wine wineboot
	winetricks -q corefonts eufonts lucida opensymbol tahoma cjkfonts
	winetricks -q vb6run
	winetricks -q mdac28
	winetricks -q msxml4 mfc42 jet40 native_oleaut32
fi

exit 0
