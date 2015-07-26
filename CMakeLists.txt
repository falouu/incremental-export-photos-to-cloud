cmake_minimum_required (VERSION 2.8)

project (photoExporter)

set( BIN_FILE_NAME "photoExporter")
set( BIN_LINK_PATH "${CMAKE_INSTALL_PREFIX}/bin/${BIN_FILE_NAME}" )
set( LIB_DIR_REL "lib/${PROJECT_NAME}" )
set( BIN_LOCAL_FILE_PATH "${CMAKE_SOURCE_DIR}/app/${BIN_FILE_NAME}" )

FILE(GLOB scripts ${CMAKE_SOURCE_DIR}/app/*.sh)

install(PROGRAMS ${scripts} DESTINATION ${LIB_DIR_REL} )
install(PROGRAMS ${BIN_LOCAL_FILE_PATH} DESTINATION ${LIB_DIR_REL} )

install(CODE "
	execute_process(
		COMMAND ${CMAKE_COMMAND}
			-DPROJECT_NAME='${PROJECT_NAME}'
			-DBIN_FILE_PATH='${LIB_DIR_REL}/${BIN_FILE_NAME}'
			-DBIN_LINK_PATH='${BIN_LINK_PATH}'
			-P
			cmake_install_bin.cmake
	)
	list(APPEND CMAKE_INSTALL_MANIFEST_FILES \"${BIN_LINK_PATH}\")
")

add_custom_target(uninstall COMMAND xargs rm < install_manifest.txt)