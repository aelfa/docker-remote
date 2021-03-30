#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2021, MrDoob
# All rights reserved.
#
# shellcheck disable=SC2086
# shellcheck disable=SC2002
# shellcheck disable=SC2006

if [[ ! -z "$BACKUP" ]];then
    echo $BACKUP
    # Set arguments
    if [[ "$#" -eq "0" ]];then
        set -- "$@" $BACKUP
    fi
fi

CMD="/usr/bin/echo $@"
echo $CMD
$CMD

# If error, print the error
if [ $? -ne 0 ];then
    echo "Here is the output"
fi
