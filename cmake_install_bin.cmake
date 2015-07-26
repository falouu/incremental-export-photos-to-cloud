execute_process (
	COMMAND ln -sf "../${BIN_FILE_PATH}" "${BIN_LINK_PATH}"
	RESULT_VARIABLE result
	OUTPUT_VARIABLE output
)

if(${result} STREQUAL "0")
	file(APPEND install_manifest.txt "${BIN_FILE_NAME}" )
	message("-- Installing symlink: ${BIN_LINK_PATH} -> ../${BIN_FILE_PATH}")
else()
	message("-- ERROR when creating link to binary. Output: ${output}" )
endif()