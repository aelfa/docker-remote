#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2021, MrDoob
# All rights reserved.
#
# shellcheck disable=SC2086
# shellcheck disable=SC2002
# shellcheck disable=SC2006

CMD=$1
echo "${CMD}"
if [ $? -eq 0 ];then
    echo "works 22"
fi
exit 1
