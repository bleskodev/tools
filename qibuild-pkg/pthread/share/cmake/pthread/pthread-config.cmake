set(PTHREAD_LIBRARIES
  ${CTC_SYSROOT}/usr/lib/arm-linux-gnueabihf/libpthread.so
  CACHE INTERNAL "" FORCE
)

set(PTHREAD_INCLUDE_DIRS
  ${CTC_SYSROOT}/usr/include
  CACHE INTERNAL "" FORCE
)

export_lib(PTHREAD)
