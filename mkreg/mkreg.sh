#!/usr/bin/env bash

###############################################
# Script to create ODBC reg keys for dsns
# Works with Wine > 1.0 and Windows 2012/8.1
# Untested with other verisons but should work
#
# 23/08/2019
# CPasternack
# MIT License
###############################################

OUTPUTFILE_THIRTYTWO=${RANDOM}_ODBC.reg
OUTPUTFILE_SIXTYFOUR=${RANDOM}_ODBC.reg
NUMBER_OF_DSNS=0

# Key values. Default user is 'sa', using SQLSRV32.dll driver
DATABASE=""
DESCRIPTION=""
DRIVER='C:\\\\Windows\\\\system32\\\\SQLSRV32.dll'
LASTUSER="sa"
SERVER=""

# array to hold database literal names
DB_NAMES=()

# build file/directory with ODBC sources with unix newline
function build_thirtytwo () {
  echo -e 'REGEDIT4\n' >> "${OUTPUTFILE_THIRTYTWO}"
  echo -e '[HKEY_LOCAL_MACHINE\Software\ODBC]\n' >> "${OUTPUTFILE_THIRTYTWO}"
  echo -e '[HKEY_LOCAL_MACHINE\Software\ODBC\ODBC.INI]\n' >> "${OUTPUTFILE_THIRTYTWO}"
  echo -e '[HKEY_LOCAL_MACHINE\Software\ODBC\ODBC.INI\ODBC Data Sources]' >> "${OUTPUTFILE_THIRTYTWO}"
}

# create 64bit keys with unix newline
function build_sixtyfour () {
  echo -e 'REGEDIT4\n' >> "${OUTPUTFILE_SIXTYFOUR}"
  echo -e '[HKEY_LOCAL_MACHINE\Software\Wow6432Node]\n' >> "${OUTPUTFILE_SIXTYFOUR}"
  echo -e '[HKEY_LOCAL_MACHINE\Software\Wow6432Node\ODBC]\n' >> "${OUTPUTFILE_SIXTYFOUR}"
  echo -e '[HKEY_LOCAL_MACHINE\Software\Wow6432Node\ODBC\ODBC.INI]\n' >> "${OUTPUTFILE_SIXTYFOUR}"
  echo -e '[HKEY_LOCAL_MACHINE\Software\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources]' >> "${OUTPUTFILE_SIXTYFOUR}"
}

if [ -z "$1" ]
then
  echo -e "Usage: $0 [OPTION] INPUT [STREAM/FILE] (DSN.txt)\n"Output: ascii.32.'$RANDOM'_ODBC.reg, ascii.64.'$RANDOM'_ODBC.reg 
  echo -e "Options:\n -i\t\trun interactive input mode"
  exit 3
fi

# check to see if there is a single input file/stream and process
if [ $# -eq 1 ] && [ "$1" != "-i" ]
then
  # build server name/ip and connection user
  # ms ODBC doesn't store the password, so neither will we
  DB_CONNECT=()
  DB_DESC=()
  while IFS= GLOBIGNOR='*' read -r LINE
  do
    if [ ${#LINE} -gt 32 ]
    then  
      echo -e "address must be less than 32 characters."
      exit 4
    elif [ "${LINE}" == "@@" ]; then
      break
    else
      DB_CONNECT+=("${LINE}")
    fi
  # read 3 lines
  done < <(head -n "+3" $1)
  DBCONNCOUNT=${#DB_CONNECT[@]}
  # get the database names 
  while IFS= GLOBIGNORE='*' read -r LINE
  do
    if [ ${#LINE} -gt 32 ]
    then  
      echo -e "Database name must be less than 32 characters."
      exit 5
    elif [ "${LINE}" == "@@" ]; then
      continue
    elif [ "${LINE}" == "@@@" ]; then
      break
    else
      DB_NAMES+=("${LINE}")
    fi
  # start the next read on the 3rd line
  done < <(tail -n "+3" $1)
  DBCOUNT=${#DB_NAMES[@]}
  DBCOUNTSKIP=$((DBCOUNT+4))
  # get the database descriptions
  while IFS= GLOBIGNORE='*' read -r LINE
  do
    if [ ${#LINE} -gt 32 ]
    then  
      echo -e "Description must be less than 32 characters."
      exit 6 
    elif [ "${LINE}" == "@@" ]; then
      continue
    elif [ "${LINE}" == "@@@" ]; then
      continue
    elif [ "${LINE}" == "###" ]; then
      break
    else
      DB_DESC+=("${LINE}")
    fi
  done < <(tail -n "+${DBCOUNTSKIP}" $1)
  # write out the file
  build_thirtytwo
  build_sixtyfour
  for database in ${DB_DESC[*]}
  do
    echo -e \"${database}\"'="SQL Server"' | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
  done
  DBDESCCOUNT=${#DB_DESC[@]}
  echo ${DBCONNCOUNT},${DBCOUNT},${DBDESCCOUNT}
  echo ${DB_CONNECT[@]},${DB_NAMES[@]},${DB_DESC[@]}
  
  if [ "${DBCOUNT}" -ne "${DBDESCCOUNT}" ] || [ "${DBCONNCOUNT}" -ne 2 ]
  then
    echo -e "Mismatching database names and descriptions, or too many connection strings"
    exit 7
  fi
  DBWRITECOUNT=0
  for dsn in ${DB_DESC[*]}
  do
    echo -e "" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
    echo -e '[HKEY_LOCAL_MACHINE\Software\ODBC\ODBC.INI\'${dsn}] >> "${OUTPUTFILE_THIRTYTWO}"
    echo -e '[HKEY_LOCAL_MACHINE\Software\Wow6432Node\ODBC\ODBC.INI\'${dsn}] >> "${OUTPUTFILE_SIXTYFOUR}"
    echo -e '"Database"='\"${DB_NAMES[${DBWRITECOUNT}]}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
    echo -e '"Description"='\"${dsn}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
    echo -e '"Driver"='\"${DRIVER}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
    echo -e '"LastUser"='\"${DB_CONNECT[1]}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
    echo -e '"Server"='\"${DB_CONNECT[0]}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
  DBWRITECOUNT=$((DBWRITECOUNT + 1))
  done
  # run unix2dos to change line-endings
  unix2dos -7 -n "${OUTPUTFILE_THIRTYTWO}" ascii.32."${OUTPUTFILE_THIRTYTWO}"
  unix2dos -7 -n "${OUTPUTFILE_SIXTYFOUR}" ascii.64."${OUTPUTFILE_SIXTYFOUR}"
  exit 0
fi

# run in interactive (human) mode for creating odbc.reg files
if [ $# -eq 1 ] && [ "$1" == "-i" ]
then
  build_thirtytwo 
  build_sixtyfour
  echo -e "Enter Server name or IP, then [ENTER]"
  read SERVER
  echo -e "Enter sql server username, then [ENTER]"
  read LASTUSER
  echo -e "Enter database name(s) (32-char limit), one line at a time. "@@" to break" 
  while IFS= GLOBIGNORE='*' read -r LINE 
   do
    if [ "${LINE}" == "@@" ]
    then
      break
    fi
    DB_NAMES+=("${LINE}")
  done
  for dsn in ${DB_NAMES[*]}
  do
    echo -e \"${dsn}\"'="SQL Server"' | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
  done
  #echo -e "" >> "${OUTPUTFILE_THIRTYTWO}"
  #echo -e "" >> "${OUTPUTFILE_SIXTYFOUR}"
  echo -e "Enter DSN description for each database (32-char limit), one line at a time. "@@" to break"
  ARRAYCOUNT=${#DB_NAMES[@]}
  DSNCOUNT=0
  while read LINE
  do
    if [ "${LINE}" == "@@" ] || [ "${ARRAYCOUNT}" -eq "${DSNCOUNT}" ]
    then
      #echo -e "\n" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
      break
    elif [ "${DSNCOUNT}" -gt "${ARRAYCOUNT}" ]; then
      #echo -e "\n" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
      echo -e "Cannot add more descriptions than databases."
      break
    elif [ ${#LINE} -gt 32 ]; then
      #echo -e "\n" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
      echo -e "Description must be less than 32 characters."
      exit 4
    else
      echo -e "" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
      echo -e '[HKEY_LOCAL_MACHINE\Software\ODBC\ODBC.INI\'${LINE}] >> "${OUTPUTFILE_THIRTYTWO}"
      echo -e '[HKEY_LOCAL_MACHINE\Software\Wow6432Node\ODBC\ODBC.INI\'${LINE}] >> "${OUTPUTFILE_SIXTYFOUR}"
      echo -e '"Database"='\"${DB_NAMES[${DSNCOUNT}]}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
      echo -e '"Description"='\"${LINE}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
      echo -e '"Driver"='\"${DRIVER}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
      echo -e '"LastUser"='\"${LASTUSER}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
      echo -e '"Server"='\"${SERVER}\" | tee -a "${OUTPUTFILE_THIRTYTWO}" | tee -a "${OUTPUTFILE_SIXTYFOUR}"
    fi
  DSNCOUNT=$((DSNCOUNT + 1))
  done < /dev/stdin
  # run unix2dos to change line-endings
  unix2dos -7 -n "${OUTPUTFILE_THIRTYTWO}" ascii.32."${OUTPUTFILE_THIRTYTWO}"
  unix2dos -7 -n "${OUTPUTFILE_SIXTYFOUR}" ascii.64."${OUTPUTFILE_SIXTYFOUR}"
  exit 0
else 
  echo -e "Usage: $0 [OPTION] INPUT [STREAM/FILE] (DSN.txt)\n"Output: ascii.32.'$RANDOM'_ODBC.reg, ascii.64.'$RANDOM'_ODBC.reg 
  echo -e "Options:\n -i\t\trun interactive input mode"
  exit 2
fi
exit 0
