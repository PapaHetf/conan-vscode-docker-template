# ============================================================
# Project Configuration for CMake
# ============================================================
# Подключается из CMakeLists.txt:
#   include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/project-config.cmake")
#
# Переменные можно переопределить через окружение:
#   export PROJECT_NAME=my_app
#   export PROJECT_VERSION_MAJOR=1
#   export PROJECT_VERSION_MINOR=2
#   export PROJECT_VERSION_PATCH=3
# ============================================================

# Имя проекта (из окружения или запасное значение)
if(NOT DEFINED ENV{PROJECT_NAME})
    set(PROJECT_NAME "my_app")
else()
    set(PROJECT_NAME $ENV{PROJECT_NAME})
endif()

# Версия (major.minor.patch)
if(NOT DEFINED ENV{PROJECT_VERSION_MAJOR})
    set(PROJECT_VERSION_MAJOR "0")
else()
    set(PROJECT_VERSION_MAJOR $ENV{PROJECT_VERSION_MAJOR})
endif()

if(NOT DEFINED ENV{PROJECT_VERSION_MINOR})
    set(PROJECT_VERSION_MINOR "1")
else()
    set(PROJECT_VERSION_MINOR $ENV{PROJECT_VERSION_MINOR})
endif()

if(NOT DEFINED ENV{PROJECT_VERSION_PATCH})
    set(PROJECT_VERSION_PATCH "0")
else()
    set(PROJECT_VERSION_PATCH $ENV{PROJECT_VERSION_PATCH})
endif()

# Строка версии
set(PROJECT_VERSION_STRING "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")

# Имя исполняемого файла: program-{major}.{minor}.{patch}
set(TARGET_NAME "program-${PROJECT_VERSION_STRING}")

message(STATUS "Project: ${PROJECT_NAME} ${PROJECT_VERSION_STRING}")
message(STATUS "Target:  ${TARGET_NAME}")