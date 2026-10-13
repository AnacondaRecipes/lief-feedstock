cmake_minimum_required(VERSION 3.12)
project(test-lief-self)

find_package(LIEF REQUIRED)

add_executable(test-lief-self test-lief-self.cpp)
target_link_libraries(test-lief-self LIEF::LIEF)
