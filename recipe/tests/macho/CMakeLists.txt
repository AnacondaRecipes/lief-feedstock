cmake_minimum_required(VERSION 3.12)
project(test-lief-macho)

find_package(LIEF REQUIRED)

add_executable(test-lief-macho test-lief-macho.cpp)
target_link_libraries(test-lief-macho LIEF::LIEF)
