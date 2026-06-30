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

# Загружаем конфигурацию проекта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../project-config.sh"

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

if [ "$BUILD_ENV" = "docker" ]; then
    # Собираем аргументы в строку для передачи в docker
    ARGS_STR=""
    if [ ${#ARGS[@]} -gt 0 ]; then
        ARGS_STR="${ARGS[@]}"
    fi

    docker run --rm \
        -v $(pwd):/workspace \
        -e PROJECT_NAME=$PROJECT_NAME \
        -e PROJECT_VERSION_MAJOR=$PROJECT_VERSION_MAJOR \
        -e PROJECT_VERSION_MINOR=$PROJECT_VERSION_MINOR \
        -e PROJECT_VERSION_PATCH=$PROJECT_VERSION_PATCH \
        conan-builder bash -c \
        "cd /workspace && \
         conan install . --build=missing -s build_type=$BUILD_TYPE && \
         conan build . -s build_type=$BUILD_TYPE && \
         ./build/$BUILD_TYPE/bin/$TARGET_NAME $ARGS_STR"
else
    conan build . -s build_type=$BUILD_TYPE
    ./build/$BUILD_TYPE/bin/$TARGET_NAME "${ARGS[@]}"
fi