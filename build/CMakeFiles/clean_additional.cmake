# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/ThemeJson_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/ThemeJson_autogen.dir/ParseCache.txt"
  "ThemeJson_autogen"
  )
endif()
