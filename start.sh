#!/bin/sh

usage() {
  echo "Usage: <backup|restore> <appname> <remote>"
  echo ""
  echo "Example (backup): backup appname remote"
  echo ""
  echo "Example (restore): restore appname remote"
  exit
}

backup() {
  echo "testbackup = ${1} ${2} ${3}"
}

restore() {
  echo "testrestore = ${1} ${2} ${3}"
}

# CHECK ARE 3 ARGUMENTES
if [[ $# -ne 3 ]]; then
  usage
fi

# ARGUMENTES
OPERATION=$1
ARCHIVE=$2.tar.gz
REMOTE=$3

# RUNNER
case "$OPERATION" in
 "backup" ) backup ;;
 "restore" ) restore ;;
 * ) usage ;;
esac
