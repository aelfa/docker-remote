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
ARCHIVEROOT="/${OPERATION}/${ARCHIVE}"

## start ##

   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE}"
   if [[ ! -x "$(command -v rsync)" ]];then
      apk --quiet --no-cache --no-progress update && \
      apk --quiet --no-cache --no-progress upgrade
      inst="rsync bc pigz tar"
      for i in ${inst};do
         apk --quiet --no-cache --no-progress add $i && echo "depends install of $i"
      done
   fi
   echo "Start tar for ${ARCHIVETAR}"
      ###cd ${ARCHIVEROOT} && tar ${OPTIONSTAR} -C ${ARCHIVE} -cf ${ARCHIVEROOT}/${ARCHIVETAR} ./
      tar ${OPTIONSTAR} -C ${ARCHIVEROOT}/ -cf ${ARCHIVEROOT}/${ARCHIVETAR} ./
   echo "Finished tar for ${ARCHIVETAR}"
   if [[ ! -d ${DESTINATION} ]];then $(command -v mkdir) -p ${DESTINATION};fi
      $(command -v rsync) -aqvh --remove-source-files --info=progress2 ${ARCHIVEROOT}/${ARCHIVETAR} ${DESTINATION}/${ARCHIVETAR}
      $(command -v chown) -hR 1000:1000 ${DESTINATION}
      echo "Finished rsync for ${ARCHIVETAR} to ${DESTINATION}"
   ## ENDING ##
   ENDTIME=$(date +%s)
   TIME="$((count=${ENDTIME}-${STARTTIME}))"
   duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
   echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE}"
}

## restore specific app
restore() {
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
DESTINATION="/mnt/unionfs/appbackups"
ARCHIVEROOT="/${OPERATION}/${ARCHIVE}"

## start ##

   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE}"
   if [[ ! -f ${DESTINATION}/${ARCHIVETAR} ]];then noarchivefound;fi
   if [[ ! -x "$(command -v rsync)" ]];then
      apk --quiet --no-cache --no-progress update && \
      apk --quiet --no-cache --no-progress upgrade
      inst="rsync bc tar"
      for i in ${inst};do
         apk --quiet --no-cache --no-progress add $i && echo "depends install of $i"
      done
   fi
   if [[ ! -d ${ARCHIVEROOT} ]];then $(command -v mkdir) -p ${ARCHIVEROOT};fi
      $(command -v rsync) -aqvh --info=progress2 ${DESTINATION}/${ARCHIVETAR} ${ARCHIVEROOT}/${ARCHIVETAR}
      $(command -v chown) -hR 1000:1000 ${DESTINATION}
   echo "Finished rsync for ${ARCHIVETAR} from ${DESTINATION}"
   if [[ ! -f ${ARCHIVEROOT}/${ARCHIVETAR} ]];then nolocalfound;fi
      echo "Start untar for ${ARCHIVETAR} on ${ARCHIVEROOT}"
      ###cd ${ARCHIVEROOT} && tar -xvf ${ARCHIVETAR}
      tar -xf ${ARCHIVEROOT}/${ARCHIVETAR} -C ${ARCHIVEROOT}
      $(command -v chown) -hR 1000:1000 ${ARCHIVEROOT}
      $(command -v rm) -f ${ARCHIVEROOT}/${ARCHIVETAR}      
   ## ENDING ##
   ENDTIME=$(date +%s)
   TIME="$((count=${ENDTIME}-${STARTTIME}))"
   duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
   echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE}"
}

noarchivefound() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
DESTINATION="/mnt/unionfs/appbackups"

tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , we could not found ${ARCHIVETAR} on ${DESTINATION}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 10 && exit
}

nolocalfound() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
DESTINATION="/mnt/unionfs/appbackups"
ARCHIVEROOT="/${OPERATION}/${ARCHIVE}"

tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , we could not found ${ARCHIVETAR} on /${OPERATION}/${ARCHIVE}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 10 && exit
}

## check specific app of existing
check() {
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
ARCHIVETAR=${ARCHIVE}.tar.gz
DESTINATION="/mnt/unionfs/appbackups"

## start ##
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE}"
   if [[ -f ${DESTINATION}/${ARCHIVETAR} ]];then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    👍
    We found ${ARCHIVETAR} on ${DESTINATION}/${ARCHIVETAR}
    You can restore or create a new backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
else
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , we could not found ${ARCHIVETAR} on ${DESTINATION}
    You need to create a backup before you can restore
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
fi
sleep 10 && exit
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
