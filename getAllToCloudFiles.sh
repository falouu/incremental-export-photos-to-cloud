#!/usr/bin/env bash

DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source "$DIR/functions.sh"

getAllToCloudFiles $@
exit $?