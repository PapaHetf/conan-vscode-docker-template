cmake_minimum_required(VERSION 3.15)

# Подключаем конфигурацию проекта из отдельного файла
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/project-config.cmake")

project(${PROJECT_NAME} VERSION ${PROJECT_VERSION_STRING})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Поиск зависимостей, установленных через Conan
find_package(fmt CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

file(GLOB_RECURSE SOURCES "src/*.cpp")
file(GLOB_RECURSE HEADERS "include/*.h")

add_executable(${TARGET_NAME} ${SOURCES})

target_include_directories(${TARGET_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Линковка с библиотеками из Conan
target_link_libraries(${TARGET_NAME} PRIVATE
    spdlog::spdlog
)

# Явно указать где класть бинарник
set_target_properties(${TARGET_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

install(TARGETS ${TARGET_NAME} DESTINATION bin)