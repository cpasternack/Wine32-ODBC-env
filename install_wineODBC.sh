#!/usr/bin/env bash

#
#
#

set -e
# Set winedebug to quiet, we don't need all the 'FIXME:' output
export WINEDEBUG=-all

# if there isn't a wineprefix or we weren't passed one, create one
if [ ! -z "${WINEPREFIX}" ] || [ -z "${2}"  ]
then
	${WINEARCH} ${WINEPREFIX} wine wineboot
	winetricks -q corefonts eufonts lucida opensymbol tahoma cjkfonts
	winetricks -q vb6run
	winetricks -q mdac28
	winetricks -q msxml4 mfc42 jet40 native_oleaut32
elif [ ! -z "${2}" ] && [ "${1}" =~ "win" ]
then
  if [ -d "${2}" ]
  then
	${1} ${2} wine wineboot
	winetricks -q corefonts eufonts lucida opensymbol tahoma cjkfonts
	winetricks -q vb6run
	winetricks -q mdac28
	winetricks -q msxml4 mfc42 jet40 native_oleaut32
  fi
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

exit $?
