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
# Также можно использовать .env файл в корне проекта:
#   PROJECT_NAME=my_app
#   PROJECT_VERSION_MAJOR=1
#
# Приоритет (от высшего к низшему):
#   1. Переменные окружения (export)
#   2. .env файл
#   3. Значения по умолчанию (ниже)
#
# Использование в shell:
#   source ./project-config.sh
#   echo $TARGET_NAME  # program-1.2.3
#
# Использование в CMake:
#   include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/project-config.cmake")
# ============================================================

# Загружаем .env файл, если он существует (не перезаписывает существующие переменные)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}" && pwd)"
if [ -f "${PROJECT_DIR}/.env" ]; then
    # Читаем .env, пропуская комментарии и пустые строки
    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Пропускаем комментарии и пустые строки
        case "$key" in
            ''|\#*) continue ;;
        esac
        # Устанавливаем только если переменная ещё не задана
        if [ -z "${!key+x}" ]; then
            export "$key=$value"
        fi
    done < "${PROJECT_DIR}/.env"
fi

export PROJECT_NAME="${PROJECT_NAME:-my_app}"
export PROJECT_VERSION_MAJOR="${PROJECT_VERSION_MAJOR:-0}"
export PROJECT_VERSION_MINOR="${PROJECT_VERSION_MINOR:-1}"
export PROJECT_VERSION_PATCH="${PROJECT_VERSION_PATCH:-0}"

export PROJECT_VERSION_STRING="${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
export TARGET_NAME="program-${PROJECT_VERSION_STRING}"