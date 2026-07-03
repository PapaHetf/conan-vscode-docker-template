#!/bin/bash

# Run script for Conan project
# Usage: ./scripts/run.sh [Release|Debug] [local|docker] [-- args...]
#
# Examples:
#   ./scripts/run.sh Release local
#   ./scripts/run.sh Debug docker
#   ./scripts/run.sh Release docker -- --help
#   ./scripts/run.sh Release docker -- --input data.txt --verbose

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Активируем виртуальное окружение (если есть)
if [ -f "${PROJECT_DIR}/.venv/bin/activate" ]; then
    source "${PROJECT_DIR}/.venv/bin/activate"
fi

# Загружаем конфигурацию проекта
source "${PROJECT_DIR}/project-config.sh"

BUILD_TYPE=${1:-Release}
BUILD_ENV=${2:-local}

# Всё, что после "--", считаем аргументами для программы
ARGS=()
if [[ "$*" == *"--"* ]]; then
    ARGS=("${@:3}")
    # Удаляем всё до "--" включительно
    while [[ "${ARGS[0]}" != "--" && ${#ARGS[@]} -gt 0 ]]; do
        ARGS=("${ARGS[@]:1}")
    done
    # Удаляем сам "--"
    if [[ "${ARGS[0]}" == "--" ]]; then
        ARGS=("${ARGS[@]:1}")
    fi
fi

echo "Running $BUILD_TYPE configuration..."
echo "Project: $PROJECT_NAME $PROJECT_VERSION_STRING"
echo "Target:  $TARGET_NAME"
if [ ${#ARGS[@]} -gt 0 ]; then
    echo "Args:    ${ARGS[@]}"
fi

cd "${PROJECT_DIR}"

if [ "$BUILD_ENV" = "docker" ]; then
    # Собираем аргументы в строку для передачи в docker
    ARGS_STR=""
    if [ ${#ARGS[@]} -gt 0 ]; then
        ARGS_STR="${ARGS[@]}"
    fi

    docker compose run --rm conan-builder bash -c \
        "cd /workspace && \
         conan install . --build=missing -s build_type=$BUILD_TYPE && \
         conan build . && \
         ./build/$BUILD_TYPE/bin/$TARGET_NAME $ARGS_STR"
else
    conan install . --build=missing -s build_type=$BUILD_TYPE
    conan build .
    ./build/$BUILD_TYPE/bin/$TARGET_NAME "${ARGS[@]}"
fi