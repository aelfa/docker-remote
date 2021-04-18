#!/usr/bin/with-contenv bash
# shellcheck shell=bash
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
      cd /${OPERATION}/${ARCHIVE} && tar ${OPTIONSTAR} -C ${ARCHIVE} -cf ${ARCHIVETAR} ./
   echo "Finished tar for ${ARCHIVE}"
   if [[ ! -d ${DESTINATION} ]];then $(command -v mkdir) -p ${DESTINATION};fi
      $(command -v rsync) -aq --info=progress2 -hv --remove-source-files /${OPERATION}/${ARCHIVE}/${ARCHIVETAR} ${DESTINATION}/${ARCHIVETAR}
      $(command -v chown) -hR 1000:1000 ${DESTINATION}/${ARCHIVETAR}
   echo "Finished rsync for ${ARCHIVETAR} to ${DESTINATION}"
   ## ENDING ##
   ENDTIME=$(date +%s)
   TIME="$((count=${ENDTIME}-${STARTTIME}))"
   duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
   echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE}"
}
backuppw() {
STARTTIME=$(date +%s)
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
ARCHIVETAR=${ARCHIVE}.tar.gz
DESTINATION="/mnt/downloads/appbackups"
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
   echo "Start protect-tar for ${PASSWORDTAR}"
      cd /${OPERATION}/${ARCHIVE} && tar ${OPTIONSTARPW} -cz ${ARCHIVE}/ | openssl enc -aes-256-cbc -e -pass pass:${PASSWORD} > ${ARCHIVEROOT}/${PASSWORDTAR}
   echo "Finished protect-tar for ${PASSWORDTAR}"
   if [[ ! -d ${DESTINATION} ]];then $(command -v mkdir) -p ${DESTINATION};fi
      $(command -v rsync) -aq --info=progress2 -hv --remove-source-files /${OPERATION}/${ARCHIVE}/${PASSWORDTAR} ${DESTINATION}/${PASSWORDTAR}
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
PASSWORD=${PASSWORD}
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
DESTINATION="/mnt/unionfs/appbackups"
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
   if [[ ! -d /${OPERATION}/${ARCHIVE} ]];then $(command -v mkdir) -p /${OPERATION}/${ARCHIVE};fi
      $(command -v rsync) -aq --info=progress2 -hv ${DESTINATION}/${ARCHIVETAR} /${OPERATION}/${ARCHIVE}/${ARCHIVETAR}
      $(command -v chown) -hR 1000:1000 /${OPERATION}/${ARCHIVE}
   echo "Finished rsync for ${ARCHIVETAR} from ${DESTINATION}"
   if [[ ! -f /${OPERATION}/${ARCHIVE}/${ARCHIVETAR} ]];then nolocalfound;fi
   echo "Start untar for ${ARCHIVETAR} on /${OPERATION}/${ARCHIVE}"
      cd /${OPERATION}/${ARCHIVE}/ && tar -zxvf ${ARCHIVETAR}
      $(command -v chown) -hR 1000:1000 /${OPERATION}/${ARCHIVE}
      $(command -v rm) -f /${OPERATION}/${ARCHIVE}/${ARCHIVETAR}
   echo "Finished untar for ${ARCHIVETAR}"
   ## ENDING ##
   ENDTIME=$(date +%s)
   TIME="$((count=${ENDTIME}-${STARTTIME}))"
   duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
   echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE}"
}
restorepw() {
STARTTIME=$(date +%s)
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
DESTINATION="/mnt/downloads/appbackups"
## start ##
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE}"
   if [[ ! -f ${DESTINATION}/${ARCHIVETAR} ]];then noarchivefoundpw;fi
   if [[ ! -x "$(command -v rsync)" ]];then
      apk --quiet --no-cache --no-progress update && \
      apk --quiet --no-cache --no-progress upgrade
      inst="rsync bc tar"
      for i in ${inst};do
         apk --quiet --no-cache --no-progress add $i && echo "depends install of $i"
      done
   fi
   if [[ ! -d /${OPERATION}/${ARCHIVE} ]];then $(command -v mkdir) -p ${ARCHIVEROOT};fi
      $(command -v rsync) -aq --info=progress2 -hv ${DESTINATION}/${PASSWORDTAR} /${OPERATION}/${ARCHIVE}/${PASSWORDTAR}
      $(command -v chown) -hR 1000:1000 ${DESTINATION}
   echo "Finished rsync for ${PASSWORDTAR} from ${DESTINATION}"
   if [[ ! -f /${OPERATION}/${ARCHIVE}/${PASSWORDTAR} ]];then nolocalfoundpw;fi
   echo "Start protect-untar for ${PASSWORDTAR} on ${ARCHIVEROOT}"
      cd /${OPERATION}/${ARCHIVE}/ && openssl aes-256-cbc -pass pass:${PASSWORD} -d -in ${PASSWORDTAR} | tar xzvf
      $(command -v chown) -hR 1000:1000 ${ARCHIVEROOT}
      $(command -v rm) -f /${OPERATION}/${ARCHIVE}/${PASSWORDTAR}
   echo "Finished protect-untar for ${PASSWORDTAR}"
   ## ENDING ##
   ENDTIME=$(date +%s)
   TIME="$((count=${ENDTIME}-${STARTTIME}))"
   duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
   echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE}"
   exit
}
noarchivefoundpw() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
ARCHIVETAR=${ARCHIVE}.tar.gz
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
DESTINATION="/mnt/unionfs/appbackups"
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${PASSWORDTAR} on ${DESTINATION}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 10 && exit
}
noarchivefound() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
ARCHIVETAR=${ARCHIVE}.tar.gz
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
DESTINATION="/mnt/unionfs/appbackups"
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${ARCHIVETAR} on ${DESTINATION}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 10 && exit
}
nolocalfoundpw() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${PASSWORDTAR} on /${OPERATION}/${ARCHIVE}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 10 && exit
}
nolocalfound() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
ARCHIVETAR=${ARCHIVE}.tar.gz
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${ARCHIVETAR} on /${OPERATION}/${ARCHIVE}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
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
sleep 10 && exit
fi
}
checkpw() {
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
ARCHIVETAR=${ARCHIVE}.tar.gz
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
DESTINATION="/mnt/unionfs/appbackups"
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
# RUN PROTECTION #
if [[ $# -eq 3 ]];then
case "$OPERATION" in
 "backup" ) backuppw ;;
 "check" ) checkpw ;;
 "restore" ) restorepw ;;
esac
fi
# RUN NO-PROTECTION #
if [[ $# -eq 2 ]];then
case "$OPERATION" in
 "backup" ) backup ;;
 "check" ) check ;;
 "restore" ) restore ;;
esac
fi
#EOF