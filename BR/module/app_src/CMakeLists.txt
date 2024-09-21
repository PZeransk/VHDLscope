cmake_minimum_required(VERSION 3.20)

project(vhdlscope_app C)
set(C_STANDARD 11)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
include(FetchContent)

add_executable(vhdlscope_app main.c)
target_include_directories(vhdlscope_app PUBLIC "/usr/include")