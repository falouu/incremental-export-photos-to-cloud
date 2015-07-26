#!/usr/bin/env bash

DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

source "$DIR/functions.sh"

isToCloud $@
declare result=$?

if [[ "$result" == $TRUE_STATUS ]]; then
	message="The file will be exported to cloud"
else
	message="The file is not for cloud"
fi

displayMessage "$message"

exit $result