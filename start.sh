#!/usr/bin/with-contenv sh
# shellcheck shell=sh
# Copyright (c) 2021, MrDoob
# All rights reserved
# Idee from scorb/docker-volume-backup
# customizable: yes
# fork allowing: yes
# modification allowed: yes
######

usage() {
  echo "Usage: <backup|restore|check> <appname> <remote>"
  echo ""
  echo "Example (backup): <backup> <appname> <remote>"
  echo ""
  echo "Example (restore): <restore> <appname> <remote>"
  echo ""
  echo "Example (check): <check> <appname> <remote>"
  exit
}

## backup specific app
backup() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
REMOTE=${REMOTE}
   echo "test backup command = ${OPERATION} ${ARCHIVE} ${REMOTE}"
        if [[ ! -d /${OPERATION}/${ARCHIVE} ]];then mkdir -p /${OPERATION}/${ARCHIVE};fi
   echo "folder /${OPERATION}/${ARCHIVE} created"
}

## restore specific app
restore() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
REMOTE=${REMOTE}
   echo "test restore command = ${OPERATION} ${ARCHIVE} ${REMOTE}"
         if [[ ! -d /${OPERATION}/${ARCHIVE} ]];then mkdir -p /${OPERATION}/${ARCHIVE};fi
   echo "folder /${OPERATION}/${ARCHIVE} created"
}

## check specific app of existing
check() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
REMOTE=${REMOTE}
   echo "test check command = ${OPERATION} ${ARCHIVE} ${REMOTE}"
        if [[ ! -d /${OPERATION}/${ARCHIVE} ]];then mkdir -p /${OPERATION}/${ARCHIVE};fi
   echo "folder /${OPERATION}/${ARCHIVE} created"
}

# CHECK ARE 3 ARGUMENTES #
if [[ $# -ne 3 ]];then usage;fi

# ARGUMENTES #
OPERATION=$1
ARCHIVE=$2
ARCHIVETAR=$2.tar.gz
REMOTE=$3

# RUNNER #
case "$OPERATION" in
 "backup" ) backup ;;
 "check" ) check ;;
 "restore" ) restore ;;
 * ) usage ;;
esac
