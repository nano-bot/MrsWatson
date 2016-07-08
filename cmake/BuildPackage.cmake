cmake_minimum_required(VERSION 3.0)

execute_process(COMMAND
  git describe --abbrev=0 --tags
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE mw_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(mw_package_DIR "${CMAKE_BINARY_DIR}/MrsWatson-${mw_PLATFORM}-${mw_VERSION}")

add_custom_target(build_package
  COMMAND ${CMAKE_COMMAND} -E make_directory "${mw_package_DIR}"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${mw_package_DIR}/docs"
  COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/LICENSE.txt" "${mw_package_DIR}"
  COMMAND ${CMAKE_COMMAND} -P "${mw_cmake_scripts_DIR}/ConvertMarkdownFiles.cmake" "${mw_package_DIR}"
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)
