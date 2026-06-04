# Prebuilt office_oxide.dll from build hook or `dart run tool/install.dart`.
cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "office_oxide_ffi")
project(${PROJECT_NAME} LANGUAGES C)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|ARM64")
  set(OFFICE_OXIDE_ARCH "arm64")
else()
  set(OFFICE_OXIDE_ARCH "x64")
endif()

set(_LIB_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/../native/windows/${OFFICE_OXIDE_ARCH}/lib/office_oxide.dll"
)

if(EXISTS "${_LIB_PATH}")
  set(office_oxide_ffi_bundled_libraries "${_LIB_PATH}" PARENT_SCOPE)
else()
  set(office_oxide_ffi_bundled_libraries "" PARENT_SCOPE)
endif()
