cmake_minimum_required(VERSION 3.15)
project(ex_conan)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB_RECURSE SOURCES "src/*.cpp")
file(GLOB_RECURSE HEADERS "include/*.h")

add_executable(ex_conan_app ${SOURCES})

target_include_directories(ex_conan_app PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Явно указать где класть бинарник
set_target_properties(ex_conan_app PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

install(TARGETS ex_conan_app DESTINATION bin)