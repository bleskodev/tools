# CMake toolchain file to cross compile for Raspberry PI
# on linux 64 host using official Rasberian toolchain.
# Adapted from Aldebaran Robotics atom toolchain
# (Copyright (C) 2011, 2012 Aldebaran Robotics).

# Altough the code look complex, all it does is:

# * Set CMAKE_FIND_ROOT_PATH and CMAKE_FIND_ROOT_MODE
# so that we find libraries in <ctc_path>/sysroot, and only
# in sysroot.
#
# * Force C and CXX compiler to make sure we use gcc from cross.

##
# Utility macros
#espace space (this allow ctc path with space)
macro(set_escaped name)
  string(REPLACE " " "\\ " ${name} ${ARGN})
endmacro()
#double!
macro(set_escaped2 name)
  string(REPLACE " " "\\\\ " ${name} ${ARGN})
endmacro()

set(TARGET_ARCH "arm")
set(TARGET_TUPLE "${TARGET_ARCH}-linux-gnueabihf")

set(CTC_CROSS   "${CMAKE_CURRENT_LIST_DIR}/")
set(CTC_SYSROOT "${CTC_CROSS}/${TARGET_TUPLE}/libc")
get_filename_component(_TC_DIR ${CMAKE_CURRENT_LIST_DIR} PATH)

##
# Define the target...
# But first, force cross-compilation, even if we are compiling
# from linux-x86 to linux-x86 ...
include(CMakeForceCompiler)
set(CMAKE_CROSSCOMPILING   ON)
# Then, define the target system
set(CMAKE_SYSTEM_NAME      "Linux")
set(CMAKE_SYSTEM_PROCESSOR ${TARGET_ARCH})
set(CMAKE_EXECUTABLE_FORMAT "ELF")

##
# Probe the build/host system...
set(_BUILD_EXT "")
# sanity checks/host detection
if(WIN32)
  if(MSVC)
    # Visual studio
    message(FATAL_ERROR "Host not suppported")
  else()
    # mingw32
    set(_BUILD_EXT ".exe")
  endif()
else()
  if(APPLE)
    # Mac OS X (assume 64bit architecture)
    set(_BUILD_EXT "")
  else()
    # Linux
    set(_BUILD_EXT "")
  endif()
endif()

# root of the cross compiled filesystem
#should be set but we do find_path in each module outside this folder !!!!
if(NOT CMAKE_FIND_ROOT_PATH)
  set(CMAKE_FIND_ROOT_PATH)
endif()
list(INSERT CMAKE_FIND_ROOT_PATH 0  "${_TC_DIR}")
# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH} CACHE INTERNAL "" FORCE)

CMAKE_FORCE_C_COMPILER(  "${CTC_CROSS}/bin/${TARGET_TUPLE}-gcc${_BUILD_EXT}" GNU)
CMAKE_FORCE_CXX_COMPILER("${CTC_CROSS}/bin/${TARGET_TUPLE}-g++${_BUILD_EXT}" GNU)

set(CMAKE_LINKER  "${CTC_CROSS}/bin/${TARGET_TUPLE}-ld${_BUILD_EXT}"      CACHE FILEPATH "" FORCE)
set(CMAKE_AR      "${CTC_CROSS}/bin/${TARGET_TUPLE}-ar${_BUILD_EXT}"      CACHE FILEPATH "" FORCE)
set(CMAKE_RANLIB  "${CTC_CROSS}/bin/${TARGET_TUPLE}-ranlib${_BUILD_EXT}"  CACHE FILEPATH "" FORCE)
set(CMAKE_NM      "${CTC_CROSS}/bin/${TARGET_TUPLE}-nm${_BUILD_EXT}"      CACHE FILEPATH "" FORCE)
set(CMAKE_OBJCOPY "${CTC_CROSS}/bin/${TARGET_TUPLE}-objcopy${_BUILD_EXT}" CACHE FILEPATH "" FORCE)
set(CMAKE_OBJDUMP "${CTC_CROSS}/bin/${TARGET_TUPLE}-objdump${_BUILD_EXT}" CACHE FILEPATH "" FORCE)
set(CMAKE_STRIP   "${CTC_CROSS}/bin/${TARGET_TUPLE}-strip${_BUILD_EXT}"   CACHE FILEPATH "" FORCE)

# If ccache is found, just use it:)
find_program(CCACHE "ccache")
if (CCACHE)
  message( STATUS "Using ccache")
endif(CCACHE)

if (CCACHE AND NOT FORCE_NO_CCACHE)
  set(CMAKE_C_COMPILER                 "${CCACHE}" CACHE FILEPATH "" FORCE)
  set(CMAKE_CXX_COMPILER               "${CCACHE}" CACHE FILEPATH "" FORCE)
  set_escaped2(CMAKE_C_COMPILER_ARG1   "${CTC_CROSS}/bin/${TARGET_TUPLE}-gcc${_BUILD_EXT}")
  set_escaped2(CMAKE_CXX_COMPILER_ARG1 "${CTC_CROSS}/bin/${TARGET_TUPLE}-g++${_BUILD_EXT}")
else(CCACHE AND NOT FORCE_NO_CCACHE)
  set_escaped(CMAKE_C_COMPILER         "${CTC_CROSS}/bin/${TARGET_TUPLE}-gcc${_BUILD_EXT}")
  set_escaped(CMAKE_CXX_COMPILER       "${CTC_CROSS}/bin/${TARGET_TUPLE}-g++${_BUILD_EXT}")
endif(CCACHE AND NOT FORCE_NO_CCACHE)

##
# Set pkg-config for cross-compilation
set(PKG_CONFIG_EXECUTABLE  "${CTC_CROSS}/bin/pkg-config" CACHE INTERNAL "" FORCE)

##
# Set target flags
set_escaped(CTC_CROSS   ${CTC_CROSS})
set_escaped(CTC_SYSROOT ${CTC_SYSROOT})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --sysroot ${CTC_SYSROOT}/")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pipe -fomit-frame-pointer")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-align-jumps -fno-align-functions")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-align-labels -fno-align-loops")

set(CMAKE_C_FLAGS        "${CMAKE_C_FLAGS}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS        "${CMAKE_C_FLAGS}" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS "-Wl,--as-needed,--sysroot,${CTC_SYSROOT}/" CACHE INTERNAL "")
set(CMAKE_MODULE_LINKER_FLAGS "-Wl,--as-needed,--sysroot,${CTC_SYSROOT}/" CACHE INTERNAL "")
set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--as-needed,--sysroot,${CTC_SYSROOT}/" CACHE INTERNAL "")

##
# Make sure we don't have to relink binaries when we cross-compile
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
