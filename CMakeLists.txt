
cmake_minimum_required(VERSION 3.15)
# Подключаем конфигурацию проекта из отдельного файла
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/project-config.cmake")

project(${PROJECT_NAME} VERSION ${PROJECT_VERSION_STRING})

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Генерировать compile_commands.json для clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Поиск зависимостей, установленных через Conan
find_package(fmt CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(PostgreSQL CONFIG REQUIRED)
find_package(libpqxx CONFIG REQUIRED)
find_package(ctre CONFIG REQUIRED)
find_package(Boost CONFIG REQUIRED COMPONENTS container program_options)
find_package(OpenSSL CONFIG REQUIRED)


set(EXTERNAL_LIBRARIES
    spdlog::spdlog
    fmt::fmt
    PostgreSQL::PostgreSQL
    libpqxx::pqxx
    ctre::ctre
    Boost::headers
    Boost::container
    Boost::program_options
    OpenSSL::Crypto
    OpenSSL::SSL
)

add_subdirectory(libraries)
add_subdirectory(src)

add_executable(${PROJECT_NAME}
    src/main.cpp
)

set_target_properties(${PROJECT_NAME} PROPERTIES 
    OUTPUT_NAME "${PROJECT_NAME}-${PROJECT_VERSION_STRING}"
)
target_link_libraries(${PROJECT_NAME}
    PUBLIC
    module_src
)

# Явно указать где класть бинарник
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)