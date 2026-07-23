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

file(GLOB_RECURSE SOURCES "src/*.cpp")
file(GLOB_RECURSE HEADERS "include/*.h")

add_executable(${TARGET_NAME} ${SOURCES})

target_include_directories(${TARGET_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Линковка с библиотеками из Conan
target_link_libraries(${TARGET_NAME} PRIVATE
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

# Явно указать где класть бинарник
set_target_properties(${TARGET_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

install(TARGETS ${TARGET_NAME} DESTINATION bin)