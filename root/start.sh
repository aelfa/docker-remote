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
  echo "Example  unencrypted (backup): <backup> <appname> <storage>"
  echo "Example unencrypted (restore): <restore> <appname> <storage>"
  echo "Example   unencrypted (check): <check> <appname> <storage>"
  echo ""
  echo "          Encrypted tar.gz.enc"
  echo "Example    encrypted (backup): <backup> <appname> <storage> <password>"
  echo "Example   encrypted (restore): <restore> <appname> <storage> <password>"
  echo "Example     encrypted (check): <check> <appname> <storage> <password>"
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
STORAGE=${STORAGE}
## start ##
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${STORAGE}"
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
   if [[ ! -d ${DESTINATION}/${STORAGE} ]];then $(command -v mkdir) -p ${DESTINATION}/${STORAGE};fi
      $(command -v rsync) -aq --info=progress2 -hv --remove-source-files /${OPERATION}/${ARCHIVE}/${ARCHIVETAR} ${DESTINATION}/${STORAGE}/${ARCHIVETAR}
      $(command -v chown) -hR 1000:1000 ${DESTINATION}/${STORAGE}/${ARCHIVETAR}
   echo "Finished rsync for ${ARCHIVETAR} to ${DESTINATION}/${STORAGE}"
   ## ENDING ##
   ENDTIME=$(date +%s)
   TIME="$((count=${ENDTIME}-${STARTTIME}))"
   duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
   echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE} ${STORAGE}"
}
backuppw() {
STARTTIME=$(date +%s)
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
ARCHIVETAR=${ARCHIVE}.tar.gz
STORAGE=${STORAGE}
DESTINATION="/mnt/downloads/appbackups"
## start ##
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${STORAGE}"
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
   if [[ ! -d ${DESTINATION}/${STORAGE} ]];then $(command -v mkdir) -p ${DESTINATION}/${STORAGE};fi
      $(command -v rsync) -aq --info=progress2 -hv --remove-source-files /${OPERATION}/${ARCHIVE}/${PASSWORDTAR} ${DESTINATION}/${STORAGE}/${PASSWORDTAR}
      $(command -v chown) -hR 1000:1000 ${DESTINATION}/${STORAGE}/${PASSWORDTAR}
   echo "Finished rsync for ${PASSWORDTAR} to ${DESTINATION}/${STORAGE}"
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
STORAGE=${STORAGE}
DESTINATION="/mnt/unionfs/appbackups"
## start ##
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${STORAGE}"
   if [[ ! -f ${DESTINATION}/${STORAGE}/${ARCHIVETAR} ]];then noarchivefound;fi
   if [[ ! -x "$(command -v rsync)" ]];then
      apk --quiet --no-cache --no-progress update && \
      apk --quiet --no-cache --no-progress upgrade
      inst="rsync bc tar"
      for i in ${inst};do
         apk --quiet --no-cache --no-progress add $i && echo "depends install of $i"
      done
   fi
   if [[ ! -d /${OPERATION}/${ARCHIVE} ]];then $(command -v mkdir) -p /${OPERATION}/${ARCHIVE};fi
      $(command -v rsync) -aq --info=progress2 -hv ${DESTINATION}/${STORAGE}/${ARCHIVETAR} /${OPERATION}/${ARCHIVE}/${ARCHIVETAR}
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
   echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE} ${STORAGE}"
}
restorepw() {
STARTTIME=$(date +%s)
## parser
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
STORAGE=${STORAGE}
DESTINATION="/mnt/unionfs/appbackups"
## start ##
   echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${STORAGE}"
   if [[ ! -f ${DESTINATION}/${STORAGE}/${ARCHIVETAR} ]];then noarchivefoundpw;fi
   if [[ ! -x "$(command -v rsync)" ]];then
      apk --quiet --no-cache --no-progress update && \
      apk --quiet --no-cache --no-progress upgrade
      inst="rsync bc tar"
      for i in ${inst};do
         apk --quiet --no-cache --no-progress add $i && echo "depends install of $i"
      done
   fi
   if [[ ! -d /${OPERATION}/${ARCHIVE} ]];then $(command -v mkdir) -p ${ARCHIVEROOT};fi
      $(command -v rsync) -aq --info=progress2 -hv ${DESTINATION}/${STORAGE}/${PASSWORDTAR} /${OPERATION}/${ARCHIVE}/${PASSWORDTAR}
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
   echo "${OPERATION} used ${duration} for ${OPERATION} ${ARCHIVE} ${STORAGE}"
   exit
}
noarchivefoundpw() {
OPERATION=${OPERATION}
ARCHIVE=${ARCHIVE}
PASSWORD=${PASSWORD}
ARCHIVETAR=${ARCHIVE}.tar.gz
PASSWORDTAR=${ARCHIVE}.tar.gz.enc
STORAGE=${STORAGE}
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
STORAGE=${STORAGE}
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
STORAGE=${STORAGE}
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
STORAGE=${STORAGE}
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
STORAGE=${STORAGE}
DESTINATION="/mnt/unionfs/appbackups"
## start ##
echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${STORAGE}"
if [[ -f ${DESTINATION}/${STORAGE}/${ARCHIVETAR} ]];then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    👍
    We found ${ARCHIVETAR} on ${DESTINATION}/${STORAGE}
    You can restore or create a new backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
else
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${ARCHIVETAR} on ${DESTINATION}/${STORAGE}
    You need to create a backup before you can restore it.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
echo "show ${OPERATION} command = ${OPERATION} ${ARCHIVE} ${STORAGE}"
if [[ -f ${DESTINATION}/${STORAGE}/${PASSWORDTAR} ]];then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    👍
    We found ${ARCHIVETAR} on ${DESTINATION}/${STORAGE}
    You can restore or create a new backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
else
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Sorry , We could not find ${ARCHIVETAR} on ${DESTINATION}/${STORAGE}
    You need to create a backup before you can restore it.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 10 && exit
fi
}
# CHECK ARE 2 ARGUMENTES #
if [[ $# -lt 3 ]];then usage;fi
if [[ $# -gt 4 ]];then usage;fi 
# ARGUMENTES #
OPERATION=$1
ARCHIVE=$2
STORAGE=$3
PASSWORD=$4
# RUN PROTECTION #
if [[ $# -eq 4 ]];then
case "$OPERATION" in
 "backup" ) backuppw ;;
 "check" ) checkpw ;;
 "restore" ) restorepw ;;
esac
fi
# RUN NO-PROTECTION #
if [[ $# -eq 3 ]];then
case "$OPERATION" in
 "backup" ) backup ;;
 "check" ) check ;;
 "restore" ) restore ;;
esac
fi
#EOF