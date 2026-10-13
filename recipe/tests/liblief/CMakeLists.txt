cmake_minimum_required(VERSION 3.15)
project(anaconda_lief_app CXX)

# Use C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Always link the shared LIEF on every platform.
find_package(LIEF REQUIRED COMPONENTS SHARED)

# Shared library that the app parses with LIEF (ELF, Mach-O or PE depending on host).
add_library(anaconda_sample SHARED sample_lib.cpp)

# The application to parse the shared library.
add_executable(anaconda_app main.cpp)

# Unvendored package include dirs should come transitively from LIEF::LIEF.
target_link_libraries(anaconda_app PRIVATE LIEF::LIEF)

# Build 'anaconda_sample' before 'anaconda_app'
add_dependencies(anaconda_app anaconda_sample)

# Parse the freshly built shared library with LIEF.
enable_testing()
add_test(NAME parse_sample_lib COMMAND anaconda_app $<TARGET_FILE:anaconda_sample>)
