# ============================================================
# Project Configuration
# ============================================================
# Этот файл используется CMakeLists.txt, conanfile.py и скриптами
# для получения имени проекта и версии.
#
# Переменные можно переопределить через окружение:
#   export PROJECT_NAME=my_app
#   export PROJECT_VERSION_MAJOR=1
#   export PROJECT_VERSION_MINOR=2
#   export PROJECT_VERSION_PATCH=3
#
# Использование в shell:
#   source ./project-config.sh
#   echo $TARGET_NAME  # program-1.2.3
#
# Использование в CMake:
#   include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/project-config.cmake")
# ============================================================

export PROJECT_NAME="${PROJECT_NAME:-my_app}"
export PROJECT_VERSION_MAJOR="${PROJECT_VERSION_MAJOR:-0}"
export PROJECT_VERSION_MINOR="${PROJECT_VERSION_MINOR:-1}"
export PROJECT_VERSION_PATCH="${PROJECT_VERSION_PATCH:-0}"

export PROJECT_VERSION_STRING="${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
export TARGET_NAME="program-${PROJECT_VERSION_STRING}"