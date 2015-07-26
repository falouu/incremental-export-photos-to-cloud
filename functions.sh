#!/usr/bin/env bash

DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

source "$DIR/settings.sh"

declare TRUE_STATUS=0
declare FALSE_STATUS=1


date=`date "+%Y-%m-%dT%H:%M:%S"`



getCommentTag() {
	declare filename="$1"
	if [ -z "$1" ]; then
		>&2 echo "ERROR: argument: not passed filename as argument 1"
		return $FALSE_STATUS
	fi

	echo $(exiftool -S -Comment "$filename" | head -1 | cut -d":" -f2)
}


isToCloud() {

	declare filename="$1"
	if [ -z "$1" ]; then
		>&2 echo "ERROR: argument: not passed filename as argument 1" > 2
		return $FALSE_STATUS
	fi

	declare comment
	comment=$(getCommentTag $filename)
	echo "$comment" | grep --quiet -E "$exportMetadataTag(;|$)"
	return $?
}


markAsToCloud() {
	declare filename="$1"
	if [ -z "$1" ]; then
		>&2 echo "ERROR: argument: not passed filename as argument 1"
		return $FALSE_STATUS
	fi

	declare comment=$(getCommentTag $filename)

	exiftool -S -Comment="$comment$exportMetadataTag" "$fileName"
}


# --files-from=FILE
#	tylko pliki wymienione w pliku FILE będą transferowane

if false; then
rsync -av --progress --link-dest="${exportDir}/exportedAll" "${scanDir}" "${exportDir}/exported-${date}" &&
	ln -sf exported-${date} ${serverPath}/exportedAll

rm exiftoolConfig
fi
