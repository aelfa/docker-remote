#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2021, MrDoob
# All rights reserved.
#
# shellcheck disable=SC2086
# shellcheck disable=SC2002
# shellcheck disable=SC2006

CMD="$@"
echo $CMD
$CMD
if [ $? -ne 0 ]
then
    echo "works"    
fi
exit 1
