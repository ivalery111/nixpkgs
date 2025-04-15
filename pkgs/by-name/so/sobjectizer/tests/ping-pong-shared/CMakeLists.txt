cmake_minimum_required(VERSION 3.8)
project(ping-pong-shared)

find_package(sobjectizer CONFIG REQUIRED)

add_executable(ping-pong-shared main.cpp)
target_link_libraries(ping-pong-shared sobjectizer::SharedLib)

install(TARGETS ping-pong-shared)
