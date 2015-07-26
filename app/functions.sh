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
	done |\
	sort -u
}


createSymlinksToNewFiles() {
	declare newFiles="$1"

	echo "Removing old 'new files'"
	rm -rf "$exportNewFilesDir"
	mkdir "$exportNewFilesDir"

	pushd "$exportNewFilesDir" > /dev/null
	echo -n "$newFiles" | while read newFile
	do
		echo "Creating link to file $newFile ..."
		mkdir -p "$(dirname $newFile)"
		pushd "$scanDir" > /dev/null
		ln -s "$(readlink -f $newFile)" "$exportNewFilesDir/$newFile"
		popd > /dev/null
	done
	popd > /dev/null
}

prepareFilesFromListToCloud() {
	if [[ -z "$1" ]] || [[ ! -f "$1" ]]; then
		>&2 echo "ERROR: first argument must be a file containing file list"
		return $FALSE_STATUS
	fi
	declare newDataFile="$1"

	if [[ ! -f "$exportedDataFile" ]]; then touch "$exportedDataFile"; fi

	echo "Calculating new files list..."
	declare newFiles=$(comm -13 "$exportedDataFile" "$newDataFile")

	if [[ -z "$newFiles" ]]; then
		echo -e "-----------------------------------"
		echo -e "  There is no new files to export"
		echo -e "-----------------------------------"
	fi

	createSymlinksToNewFiles "$newFiles"

	echo "Saving new exported file list"
	mv "$exportedDataFile" "$exportedDataFile-$date"
	mv "$newDataFile" "$exportedDataFile"

	#rsync -av --files-from=/tmp/photosExport --progress --link-dest="${exportDir}/exportedCurrent" "${scanDir}" "${exportDir}/exported-${date}" &&
	#ln -sf "exported-${date}" "${exportDir}/exportedCurrent"
}

prepareFilesToCloud() {
	declare photosExportFile=/tmp/photosExport
	echo "Scanning for flagged files..."
	pushd "${scanDir}" > /dev/null
	getAllToCloudFiles . > $photosExportFile
	popd > /dev/null

	echo "Prepering flagged files to cloud..."
	prepareFilesFromListToCloud $photosExportFile

	echo "== Files successfully prepared to cloud =="
}
