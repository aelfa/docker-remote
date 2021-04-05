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

OPTIONSTARPW="--warning=no-file-changed \
  --ignore-failed-read \
  --absolute-names \
  --warning=no-file-removed \
  --exclude-from=/backup_excludes"
#FUNCTIONS END

usage() {
  echo ""
  echo "Usage: <backup|restore|check> <appname> || <password>"
  echo ""
  echo "          Unencrypted tar.gz"
  echo "Example  unencrypted (backup): <backup> <appname>"
  echo "Example unencrypted (restore): <restore> <appname>"
  echo "Example   unencrypted (check): <check> <appname>"
  echo ""
  echo "          Encrypted tar.gz.enc"
  echo "Example    encrypted (backup): <backup> <appname> <password>"
  echo "Example   encrypted (restore): <restore> <appname> <password>"
  echo "Example     encrypted (check): <check> <appname> <password>"
  echo ""
  exit
}

## backup specific app
backup() {
STARTTIME=$(date +%s)
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
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
   if [[ ${PASSWORD} != "" ]];then passwordtar;fi
   if [[ ${PASSWORD} == "" ]];then
      echo "Start tar for ${ARCHIVETAR}"
         cd ${ARCHIVEROOT} && tar ${OPTIONSTAR} -C ${ARCHIVE} -cf ${ARCHIVETAR} ./
      echo "Finished tar for ${ARCHIVE}"
      if [[ ! -d ${DESTINATION} ]];then $(command -v mkdir) -p ${DESTINATION};fi
         $(command -v rsync) -aq --info=progress2 -hv --remove-source-files ${ARCHIVEROOT}/${ARCHIVETAR} ${DESTINATION}/${ARCHIVETAR}
         $(command -v chown) -hR 1000:1000 ${DESTINATION}/${ARCHIVETAR}
      echo "Finished rsync for ${ARCHIVETAR} to ${DESTINATION}"
      ## ENDING ##
      ENDTIME=$(date +%s)
      TIME="$((count=${ENDTIME}-${STARTTIME}))"
      duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
      echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE}"
   fi
   exit
}

passwordtar() {
STARTTIME=$(date +%s)
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
DESTINATION="/mnt/downloads/appbackups"
ARCHIVEROOT="/${OPERATION}/"

   echo "Start protect-tar for ${PASSWORDTAR}"
      cd ${ARCHIVEROOT} && tar ${OPTIONSTAR} -cz ${ARCHIVE}/ | openssl enc -aes-256-cbc -e -pass pass:${PASSWORD} > ${ARCHIVEROOT}/${PASSWORDTAR}
   echo "Finished protect-tar for ${PASSWORDTAR}"
   if [[ ! -d ${DESTINATION} ]];then $(command -v mkdir) -p ${DESTINATION};fi
      $(command -v rsync) -aq --info=progress2 -hv --remove-source-files ${ARCHIVEROOT}/${PASSWORDTAR} ${DESTINATION}/${PASSWORDTAR}
      $(command -v chown) -hR 1000:1000 ${DESTINATION}/${PASSWORDTAR}
   echo "Finished rsync for ${PASSWORDTAR} to ${DESTINATION}"
   ## ENDING ##
   ENDTIME=$(date +%s)
   TIME="$((count=${ENDTIME}-${STARTTIME}))"
   duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
   echo "${OPERATION} used ${duration} for ${OPERATION} ${PASSWORDTAR}"
}

## restore specific app
restore() {
STARTTIME=$(date +%s)
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
   if [[ ${PASSWORD} != "" ]];then restoreprotect;fi
   if [[ ${PASSWORD} == "" ]];then
         $(command -v rsync) -aq --info=progress2 -hv ${DESTINATION}/${ARCHIVETAR} ${ARCHIVEROOT}/${ARCHIVETAR}
         $(command -v chown) -hR 1000:1000 ${DESTINATION}
      echo "Finished rsync for ${ARCHIVETAR} from ${DESTINATION}"
      if [[ ! -f ${ARCHIVEROOT}/${ARCHIVETAR} ]];then nolocalfound;fi
      echo "Start untar for ${ARCHIVETAR} on ${ARCHIVEROOT}"
         cd ${ARCHIVEROOT} && tar -xvf ${ARCHIVETAR}
         $(command -v chown) -hR 1000:1000 ${ARCHIVEROOT}
         $(command -v rm) -f ${ARCHIVEROOT}/${ARCHIVETAR}
      echo "Finished untar for ${ARCHIVETAR}"
      ## ENDING ##
      ENDTIME=$(date +%s)
      TIME="$((count=${ENDTIME}-${STARTTIME}))"
      duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
      echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE}"
   fi
   exit
}

restoreprotect() {
STARTTIME=$(date +%s)
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
DESTINATION="/mnt/downloads/appbackups"
ARCHIVEROOT="/${OPERATION}/"

   if [[ ! -d ${ARCHIVEROOT} ]];then $(command -v mkdir) -p ${ARCHIVEROOT};fi
      $(command -v rsync) -aq --info=progress2 -hv ${DESTINATION}/${PASSWORDTAR} ${ARCHIVEROOT}/${PASSWORDTAR}
      $(command -v chown) -hR 1000:1000 ${DESTINATION}
   echo "Finished rsync for ${PASSWORDTAR} from ${DESTINATION}"
   if [[ ! -f ${ARCHIVEROOT}/${PASSWORDTAR} ]];then nolocalfound;fi
   echo "Start protect-untar for ${PASSWORDTAR} on ${ARCHIVEROOT}"
      cd ${ARCHIVEROOT} && openssl aes-256-cbc -pass pass:${PASSWORD} -d -in ${PASSWORDTAR} | tar xz
      $(command -v chown) -hR 1000:1000 ${ARCHIVEROOT}
      $(command -v rm) -f ${ARCHIVEROOT}/${PASSWORDTAR}
   echo "Finished protect-untar for ${PASSWORDTAR}"
   ## ENDING ##
   ENDTIME=$(date +%s)
   TIME="$((count=${ENDTIME}-${STARTTIME}))"
   duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
   echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE}"
   exit
}

noarchivefound() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
ARCHIVETAR=${ARCHIVE}.tar.gz
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
DESTINATION="/mnt/unionfs/appbackups"

if [[ ${PASSWORD} != "" ]];then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${PASSWORDTAR} on ${DESTINATION}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
else
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${ARCHIVETAR} on ${DESTINATION}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
fi
sleep 10 && exit
}

nolocalfound() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
ARCHIVETAR=${ARCHIVE}.tar.gz
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
ARCHIVEROOT="/${OPERATION}/"

if [[ ${PASSWORD} != "" ]];then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${PASSWORDTAR} on ${ARCHIVEROOT}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
else
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${ARCHIVETAR} on /${OPERATION}/${ARCHIVE}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
fi
sleep 10 && exit
}

## check specific app of existing
check() {
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
ARCHIVETAR=${ARCHIVE}.tar.gz
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
DESTINATION="/mnt/unionfs/appbackups"

## start ##
if [[ ${PASSWORD} == "" ]];then
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE}"
   if [[ -f ${DESTINATION}/${ARCHIVETAR} ]];then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    👍
    We found ${ARCHIVETAR} on ${DESTINATION}
    You can restore or create a new backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
else
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${ARCHIVETAR} on ${DESTINATION}
    You need to create a backup before you can restore it.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
   fi
sleep 10 && exit
fi
if [[ ${PASSWORD} != "" ]];then
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE}"
   if [[ -f ${DESTINATION}/${PASSWORDTAR} ]];then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    👍
    We found ${PASSWORDTAR} on ${DESTINATION}
    You can restore or create a new backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
else
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , we could not found ${PASSWORDTAR} on ${DESTINATION}
    You need to create a backup before you can restore.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
   fi
sleep 10 && exit
fi
}

# CHECK ARE 2 ARGUMENTES #
if [[ $# -lt 2 ]];then usage;fi
if [[ $# -gt 3 ]];then usage;fi 

# ARGUMENTES #
OPERATION=$1
ARCHIVE=$2
PASSWORD=$3

# RUNNER #
case "$OPERATION" in
 "backup" ) backup ;;
 "check" ) check ;;
 "restore" ) restore ;;
 * ) usage ;;
esac
