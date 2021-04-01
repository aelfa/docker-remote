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
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
REMOTE=${REMOTE}

## start
   echo "test ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${REMOTE}"
        if [ ! -d /${OPERATION}/${ARCHIVE} ];then mkdir -p /${OPERATION}/${ARCHIVE};fi
   echo "folder /${OPERATION}/${ARCHIVE} created"
        if [ ! -x "$(command -v rsync)" ] && [ ! -x "$(command -v rclone)" ];then
           apk --quiet --no-cache --no-progress update && \
           apk --quiet --no-cache --no-progress upgrade
           inst="rsync rclone bc"
           for i in ${inst};do
               apk --quiet --no-cache --no-progress add $i
               echo "depends install of $i"
           done
        fi
}

## restore specific app
restore() {
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
REMOTE=${REMOTE}

## start
   echo "test ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${REMOTE}"
        if [ ! -d /${OPERATION}/${ARCHIVE} ];then mkdir -p /${OPERATION}/${ARCHIVE};fi
   echo "folder /${OPERATION}/${ARCHIVE} created"
        if [ ! -x "$(command -v rsync)" ] && [ ! -x "$(command -v rclone)" ];then
           apk --quiet --no-cache --no-progress update && \
           apk --quiet --no-cache --no-progress upgrade
           inst="rsync rclone bc"
           for i in ${inst};do
               apk --quiet --no-cache --no-progress add $i
               echo "depends install of $i"
           done
        fi
}

## check specific app of existing
check() {
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
REMOTE=${REMOTE}

## start
   echo "test ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${REMOTE}"
        if [ ! -d /${OPERATION}/${ARCHIVE} ];then mkdir -p /${OPERATION}/${ARCHIVE};fi
   echo "folder /${OPERATION}/${ARCHIVE} created"
}

# CHECK ARE 3 ARGUMENTES #
if [ $# -ne 3 ];then usage;fi

# ARGUMENTES #
OPERATION=$1
ARCHIVE=$2
REMOTE=$3

# RUNNER #
case "$OPERATION" in
 "backup" ) backup ;;
 "check" ) check ;;
 "restore" ) restore ;;
 * ) usage ;;
esac