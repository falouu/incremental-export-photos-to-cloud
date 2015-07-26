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

	echo "$(exiftool -S -Comment "$filename" | head -1 | cut -d":" -f2 | cut -c 2-)"
}


isToCloud() {
	declare filename="$1"
	if [ -z "$1" ]; then
		>&2 echo "ERROR: argument: not passed filename as argument 1"
		return $FALSE_STATUS
	fi

	declare comment
	comment=$(getCommentTag "$filename")
	echo "$comment" | grep --quiet -E "$exportMetadataTag(;|$)"
	return $?
}


markAsToCloud() {
	declare filename="$1"
	if [ -z "$1" ]; then
		>&2 echo "ERROR: argument: not passed filename as argument 1"
		return $FALSE_STATUS
	fi

	if isToCloud "$filename"; then
		>&2 echo "ERROR: $filename is already marked as to cloud"
		return $FALSE_STATUS
	fi

	declare comment=$(getCommentTag "$filename")

	exiftool -S -Comment="$comment$exportMetadataTag" "$filename"
}


getAllToCloudFiles() {
	declare dir="$1"
	if [ -z "$1" ]; then
		>&2 echo "ERROR: argument: not passed directory as argument 1"
		return $FALSE_STATUS
	fi

	find "${dir}" -type f |\
	while read filename
	do
		isToCloud "$filename" && echo "$filename"
	done
}


# --files-from=FILE
#	tylko pliki wymienione w pliku FILE będą transferowane

prepareFilesFromListToCloud() {
	declare dir="$1"
	if [[ -z "$1" ]] || [[ ! -f "$1" ]]; then
		>&2 echo "ERROR: first argument must be a file containing file list"
		return $FALSE_STATUS
	fi

	if [[ ! -d "${exportDir}/exportedCurrent" ]]; then mkdir "${exportDir}/exportedCurrent"; fi

	echo "Preparing files to cloud..."
	rsync -av --files-from=/tmp/photosExport --progress --link-dest="${exportDir}/exportedCurrent" "${scanDir}" "${exportDir}/exported-${date}" &&
	ln -sf "exported-${date}" "${exportDir}/exportedCurrent"
}

prepareFilesToCloud() {
	declare photosExportFile=/tmp/photosExport
	echo "Getting flagged files list..."
	getAllToCloudFiles "${scanDir}" > $photosExportFile

	echo "Prepering files from list to cloud..."
	prepareFilesFromListToCloud $photosExportFile
}
