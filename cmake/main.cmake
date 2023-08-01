project(repanda VERSION "0.1.0" LANGUAGES CXX)
# https://cmake.org/cmake/help/v3.4/policy/CMP0065.html
cmake_policy(SET CMP0065 OLD)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_UNITY_BUILD_BATCH_SIZE 10)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(REPANDA_DEPS_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/deps_install
  CACHE STRING "Managed dependencies install directory")

set(REPANDA_DEPS_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/deps_build)

list(APPEND BASE_LD_FLAGS_LIST
    -L${REPANDA_DEPS_INSTALL_DIR}/lib
    -L${REPANDA_DEPS_INSTALL_DIR}/lib64
  -fuse-ld=lld)

set(PKG_CONFIG_PATH_LIST
    ${REPANDA_DEPS_INSTALL_DIR}/lib64/pkgconfig
    ${REPANDA_DEPS_INSTALL_DIR}/share/pkgconfig
    ${REPANDA_DEPS_INSTALL_DIR}/lib/pkgconfig
  )


list(APPEND BASE_CXX_FLAGS_LIST -fPIC)
list(APPEND BASE_C_FLAGS_LIST -fPIC)

if ("${CMAKE_BUILD_TYPE}" MATCHES "Debug")
    list(APPEND BASE_CXX_FLAGS_LIST
            -fsanitize=undefined
            -fsanitize=address
            )
    list(APPEND BASE_C_FLAGS_LIST
            -fsanitize=undefined
            -fsanitize=address
            )
    list(APPEND BASE_LD_FLAGS_LIST
            -fsanitize=undefined
            -fsanitize=address
            )
endif()

# included here because it modifies the BASE_*_FLAGS_LIST variables used below
include(cmake/diagnostic_colors.cmake)

# join flag lists
string(JOIN " " BASE_C_FLAGS ${BASE_C_FLAGS_LIST})
string(JOIN " " BASE_CXX_FLAGS ${BASE_CXX_FLAGS_LIST})
string(JOIN " " BASE_LD_FLAGS ${BASE_LD_FLAGS_LIST})

string(JOIN ":" PKG_CONFIG_PATH ${PKG_CONFIG_PATH_LIST})
find_package(PkgConfig REQUIRED)
set(ENV{PKG_CONFIG_PATH}  "${PKG_CONFIG_PATH}")

set(CMAKE_C_FLAGS_BUILD_TYPE ${CMAKE_C_FLAGS_${BUILD_TYPE}})
set(CMAKE_CXX_FLAGS_BUILD_TYPE ${CMAKE_CXX_FLAGS_${BUILD_TYPE}})



configure_file(cmake/oss.cmake.in ${REPANDA_DEPS_BUILD_DIR}/CMakeLists.txt @ONLY)

list(APPEND CMAKE_PREFIX_PATH "${REPANDA_DEPS_INSTALL_DIR}")

if(NOT REPANDA_DEPS_SKIP_BUILD)
  execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${REPANDA_DEPS_BUILD_DIR})
  if(result)
    message(FATAL_ERROR "CMake step for v::deps failed: ${result}")
  endif()
  execute_process(COMMAND ${CMAKE_COMMAND} --build .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${REPANDA_DEPS_BUILD_DIR})
  if(result)
    message(FATAL_ERROR "Build step for v::build failed: ${result}")
  endif()
endif()



find_package(Valgrind REQUIRED)


find_package(Seastar REQUIRED)
find_package(Boost REQUIRED
  COMPONENTS
    iostreams
    unit_test_framework)



######################################################
# ---- Create repanda executable ----
######################################################

file(GLOB_RECURSE repanda_headers CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h)
file(GLOB_RECURSE repanda_sources CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc)
add_executable(${PROJECT_NAME} ${repanda_headers} ${repanda_sources})

target_link_libraries(${PROJECT_NAME} PRIVATE Seastar::seastar)
