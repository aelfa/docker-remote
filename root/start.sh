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
STARTTIME=$(date +%s)
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
DESTINATION="/mnt/downloads/appbackups"
ARCHIVEROOT="/backup/${ARCHIVE}"

## start
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE}"
   if [ ! -x "$(command -v rsync)" ] && [ ! -x "$(command -v rclone)" ];then
      apk --quiet --no-cache --no-progress update && \
      apk --quiet --no-cache --no-progress upgrade
      inst="rsync rclone bc pigz tar"
      for i in ${inst};do
         apk --quiet --no-cache --no-progress add $i && echo "depends install of $i"
      done
   fi
   echo "Start tar for ${ARCHIVETAR}"
      cd ${ARCHIVEROOT} && tar ${OPTIONSTAR} -C ${ARCHIVE} -cf ${ARCHIVETAR} ./
   echo "Finished tar for ${ARCHIVETAR}"
   if [[ ! -d ${DESTINATION} ]];then $(command -v mkdir) -p ${DESTINATION};fi
      $(command -v rsync) -aqvh --remove-source-files --info=progress2 ${ARCHIVEROOT}/${ARCHIVETAR} ${DESTINATION}/${ARCHIVETAR}
      $(command -v chown) -hR 1000:1000 ${DESTINATION}
   echo "Finished rsync for ${ARCHIVETAR}"
   #ENDING
   ENDTIME=$(date +%s)
   TIME="$((count=${ENDTIME}-${STARTTIME}))"
   duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
   echo "used ${duration}"

}

## restore specific app
restore() {
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz

## start
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE}"
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

## start
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE}"
        if [ ! -d /${OPERATION}/${ARCHIVE} ];then mkdir -p /${OPERATION}/${ARCHIVE};fi
   echo "folder /${OPERATION}/${ARCHIVE} created"
}

# CHECK ARE 2 ARGUMENTES #
if [ $# -ne 2 ];then usage;fi

# ARGUMENTES #
OPERATION=$1
ARCHIVE=$2

# RUNNER #
case "$OPERATION" in
 "backup" ) backup ;;
 "check" ) check ;;
 "restore" ) restore ;;
 * ) usage ;;
esac
