
project(sbml-cxxwrapjl)

cmake_minimum_required(VERSION 3.10)

set(CMAKE_MACOSX_RPATH 1)
#TODO why? set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

find_package(JlCxx REQUIRED)
get_target_property(JlCxx_location JlCxx::cxxwrap_julia LOCATION)
get_filename_component(JlCxx_location ${JlCxx_location} DIRECTORY)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${JlCxx_location}")
message(STATUS "Found JlCxx at ${JlCxx_location}")

find_package(PkgConfig)

pkg_check_modules(SBML libsbml REQUIRED)

add_library(sbml-cxxwrapjl SHARED
	src/cxxwrap.cpp
	src/versions.cpp
)

target_include_directories(sbml-cxxwrapjl PUBLIC ${SBML_INCLUDEDIR})
target_link_directories(sbml-cxxwrapjl PUBLIC ${SBML_LIBDIR})
target_link_libraries(sbml-cxxwrapjl
	${SBML_LIBRARIES}
	JlCxx::cxxwrap_julia)
