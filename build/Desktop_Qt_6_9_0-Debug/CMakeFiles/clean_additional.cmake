# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/appbozankaya_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/appbozankaya_autogen.dir/ParseCache.txt"
  "appbozankaya_autogen"
  )
endif()
