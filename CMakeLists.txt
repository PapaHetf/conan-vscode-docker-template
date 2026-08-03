cmake_minimum_required(VERSION 3.24)
# Подключаем конфигурацию проекта из отдельного файла
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/project-config.cmake")

project(${PROJECT_NAME} VERSION ${PROJECT_VERSION_STRING} LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Генерировать compile_commands.json для clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ------------------------------------------------------------
# Опции (BUILD_TESTING и WITH_* выставляет conanfile.py)
# ------------------------------------------------------------
option(WITH_POSTGRES "Link libpq/libpqxx" OFF)
option(WITH_CTRE "Link ctre (compile-time regex)" OFF)
option(WITH_SPDLOG "Link spdlog" OFF)

include(CTest) # создаёт option(BUILD_TESTING)
include(cmake/CompilerWarnings.cmake)
include(cmake/Sanitizers.cmake)
include(cmake/ClangTidy.cmake)

# ------------------------------------------------------------
# Зависимости, установленные через Conan
# ------------------------------------------------------------
find_package(Threads REQUIRED)
find_package(fmt CONFIG REQUIRED)
find_package(Boost CONFIG REQUIRED COMPONENTS container program_options)
find_package(OpenSSL CONFIG REQUIRED)

set(EXTERNAL_LIBRARIES
    fmt::fmt
    Boost::headers
    Boost::container
    Boost::program_options
    OpenSSL::Crypto
    OpenSSL::SSL
)

if(WITH_SPDLOG)
    find_package(spdlog CONFIG REQUIRED)
    list(APPEND EXTERNAL_LIBRARIES spdlog::spdlog)
endif()
if(WITH_POSTGRES)
    find_package(PostgreSQL CONFIG REQUIRED)
    find_package(libpqxx CONFIG REQUIRED)
    list(APPEND EXTERNAL_LIBRARIES PostgreSQL::PostgreSQL libpqxx::pqxx)
endif()
if(WITH_CTRE)
    find_package(ctre CONFIG REQUIRED)
    list(APPEND EXTERNAL_LIBRARIES ctre::ctre)
endif()

add_subdirectory(libraries)
add_subdirectory(src)

add_executable(${PROJECT_NAME}
    src/main.cpp
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "${TARGET_NAME}"
    # Явно указать где класть бинарник
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
target_link_libraries(${PROJECT_NAME}
    PRIVATE
    module_src
)
set_project_warnings(${PROJECT_NAME})
enable_sanitizers(${PROJECT_NAME})
enable_clang_tidy(${PROJECT_NAME})

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
