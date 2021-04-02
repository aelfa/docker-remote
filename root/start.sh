#!/usr/bin/with-contenv sh
# shellcheck shell=sh
# Copyright (c) 2021, MrDoob
# All rights reserved
# Idee from scorb/docker-volume-backup
# customizable: yes
# fork allowing: yes
# modification allowed: yes
######
#FUNCTIONS START
OPTIONSTAR="--warning=no-file-changed \
  --ignore-failed-read \
  --absolute-names \
  --warning=no-file-removed \
  --exclude-from=/backup_excludes \
  --use-compress-program=pigz"

#FUNCTIONS END

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
ARCHIVEROOT="/backup/${ARCHIVE}"
## start
   $(ls ${ARCHIVEROOT}/** )
   if [ $? -ne 0 ];then exit;fi
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${REMOTE}"
   if [ ! -x "$(command -v rsync)" ] && [ ! -x "$(command -v rclone)" ];then
      apk --quiet --no-cache --no-progress update && \
      apk --quiet --no-cache --no-progress upgrade
      inst="rsync rclone bc pigz tar"
      for i in ${inst};do
         apk --quiet --no-cache --no-progress add $i && echo "depends install of $i"
      done
   fi
   echo "Start TAR for ${ARCHIVETAR}"
      cd ${ARCHIVEROOT} && tar ${OPTIONSTAR} -C ${ARCHIVE} -cf ${ARCHIVETAR} ./
   echo "Finished TAR for ${ARCHIVETAR}"

}

## restore specific app
restore() {
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
REMOTE=${REMOTE}

## start
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${REMOTE}"
   if [ ! -x "$(command -v rsync)" ] && [ ! -x "$(command -v rclone)" ];then
      apk --quiet --no-cache --no-progress update && \
      apk --quiet --no-cache --no-progress upgrade
      inst="rsync rclone bc tar"
      for i in ${inst};do
          apk --quiet --no-cache --no-progress add $i && echo "depends install of $i"
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
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${REMOTE}"
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
