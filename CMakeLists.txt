cmake_minimum_required(VERSION 4.2)

# Detect compiler
include(CheckCXXCompilerFlag)

# General compile optimizations
add_compile_options(
    -pipe
    -march=native
    -mtune=native

    -fno-var-tracking-assignments

    # Standard visibility opts
    -fvisibility=hidden
    -fvisibility-inlines-hidden

    # Unsafe fast math stack
    -Ofast
    -ffast-math
    -funsafe-math-optimizations
    -fno-math-errno
    -fno-signed-zeros
    -fno-trapping-math

    # Loop + CPU-level optimizations
    -funroll-loops
    -fstrict-overflow

    # Aggressive IPA / devirtualization (LTO required)
    -fno-semantic-interposition
    -fdevirtualize-at-ltrans
)


# Base optimization levels
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
set(CMAKE_C_FLAGS_RELEASE   "-O3 -DNDEBUG")

if(LTO_FOUND)
    message(STATUS "LTO enabled")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()

# GCC/Clang specific optimizations
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(
        -funroll-loops
        -fstrict-overflow
        -fno-math-errno
        -fmerge-all-constants
        -falign-functions=32
        -falign-jumps
        -falign-loops
    )
endif()

# GCC-only flags
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(
        -fno-plt
        -fdevirtualize-at-ltrans
        -fno-semantic-interposition
        -fipa-pta
        -fipa-cp-clone
        -fgraphite-identity
    )
endif()

# Clang-only flags
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    add_compile_options(
        -mllvm -inline-threshold=1000
    )
endif()




set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(tfs)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

add_compile_options(-pipe -march=native -fvisibility=hidden)

set(CMAKE_CXX_FLAGS_DEFAULT "-O2 -g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

if(CMAKE_COMPILER_IS_GNUCXX)
    add_compile_options(-fno-strict-aliasing)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(FindLTO)

# Find packages.
find_package(GMP REQUIRED)
find_package(PugiXML REQUIRED)
find_package(ZLIB REQUIRED)
find_package(MySQL)
find_package(Threads)
find_package(OpenSSL REQUIRED)
find_package(spdlog REQUIRED)

# Selects LuaJIT if user defines or auto-detected
if(DEFINED USE_LUAJIT AND NOT USE_LUAJIT)
    set(FORCE_LUAJIT ${USE_LUAJIT})
else()
    find_package(LuaJIT)
    set(FORCE_LUAJIT ${LuaJIT_FOUND})
endif()
option(USE_LUAJIT "Use LuaJIT" ${FORCE_LUAJIT})

if(FORCE_LUAJIT)
    if(APPLE)
      set(CMAKE_EXE_LINKER_FLAGS "-pagezero_size 10000 -image_base 100000000")
    endif()
else()
    find_package(Lua REQUIRED)
endif()

find_package(Boost 1.71.0 COMPONENTS system filesystem iostreams REQUIRED)
ADD_DEFINITIONS(-DSTATS_ENABLED)

add_subdirectory(src)
add_executable(tfs ${tfs_SRC})

include_directories(${MYSQL_INCLUDE_DIR} ${LUA_INCLUDE_DIR} ${Boost_INCLUDE_DIRS} ${PUGIXML_INCLUDE_DIR} ${GMP_INCLUDE_DIR} ${ZLIB_INCLUDE_DIR} ${OPENSSL_INCLUDE_DIR})
target_link_libraries(tfs ${MYSQL_CLIENT_LIBS} ${LUA_LIBRARIES} ${Boost_LIBRARIES} ${Boost_FILESYSTEM_LIBRARY} ${PUGIXML_LIBRARIES} ${GMP_LIBRARIES} ${ZLIB_LIBRARY} ${OPENSSL_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})
set_target_properties(tfs PROPERTIES UNITY_BUILD ON)
set_target_properties(tfs PROPERTIES UNITY_BUILD_BATCH_SIZE 8)
target_precompile_headers(tfs PRIVATE src/otpch.h)

