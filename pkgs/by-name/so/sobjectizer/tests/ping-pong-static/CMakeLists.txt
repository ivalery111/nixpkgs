cmake_minimum_required(VERSION 3.8)
project(ping-pong-static)

find_package(sobjectizer CONFIG REQUIRED)

add_executable(ping-pong-static main.cpp)
target_link_libraries(ping-pong-static sobjectizer::StaticLib)

install(TARGETS ping-pong-static)
