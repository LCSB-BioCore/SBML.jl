
project(sbml-cxxwrapjl)

cmake_minimum_required(VERSION 3.10)

set(CMAKE_VERBOSE_MAKEFILE ON)

set(CMAKE_MACOSX_RPATH 0)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

find_package(JlCxx)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${Julia_LIBRARY_DIR}")
#get_target_property(JlCxx_location JlCxx::cxxwrap_julia LOCATION)
#get_filename_component(JlCxx_location ${JlCxx_location} DIRECTORY)
#set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${JlCxx_location}")
#message(STATUS "Found JlCxx at ${JlCxx_location}")
include_directories(${Julia_INCLUDE_DIRS})
include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${INTERFACE_INCLUDE_DIRECTORIES})

find_package(PkgConfig)

pkg_check_modules(SBML libsbml REQUIRED)
message(STATUS "SBML includedir: ${SBML_INCLUDEDIR}")

add_library(sbml-cxxwrapjl SHARED
	src/cxxwrap.cpp
	src/versions.cpp
	src/readsbml.cpp
)

target_include_directories(sbml-cxxwrapjl SYSTEM PUBLIC ${SBML_INCLUDEDIR})
target_link_directories(sbml-cxxwrapjl PUBLIC ${SBML_LIBDIR})
target_link_libraries(sbml-cxxwrapjl
	${SBML_LIBRARIES}
	JlCxx::cxxwrap_julia)

install(TARGETS sbml-cxxwrapjl)
