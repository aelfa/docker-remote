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
  echo "$1 $2 $3"
}

restore() {
  echo "$1 $2 $3"
}

sleep 1

if [ $# -ne 2 ]; then
  usage
fi

OPERATION=$1
ARCHIVE=$2.tar.gz
REMOTE=$3

case "$OPERATION" in
"backup" )
  backup
  ;;
"restore" )
  restore
  ;;
* )
  usage
  ;;
esac
