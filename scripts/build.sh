#!/bin/bash

# Build script for Conan project
# Usage: ./scripts/build.sh [Release|Debug] [local|docker]
#
# Examples:
#   ./scripts/build.sh Release local
#   ./scripts/build.sh Debug docker
#   PROJECT_NAME=my_app PROJECT_VERSION_MAJOR=2 ./scripts/build.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Активируем виртуальное окружение (если есть)
if [ -f "${SCRIPT_DIR}/../.venv/bin/activate" ]; then
    source "${SCRIPT_DIR}/../.venv/bin/activate"
fi

# Загружаем конфигурацию проекта
source "${SCRIPT_DIR}/../project-config.sh"

BUILD_TYPE=${1:-Release}
BUILD_ENV=${2:-local}

echo "Building $BUILD_TYPE configuration in $BUILD_ENV environment..."
echo "Project: $PROJECT_NAME $PROJECT_VERSION_STRING"
echo "Target:  $TARGET_NAME"

if [ "$BUILD_ENV" = "docker" ]; then
    docker build -t conan-builder .
    docker run --rm \
        -v $(pwd):/workspace \
        -e PROJECT_NAME=$PROJECT_NAME \
        -e PROJECT_VERSION_MAJOR=$PROJECT_VERSION_MAJOR \
        -e PROJECT_VERSION_MINOR=$PROJECT_VERSION_MINOR \
        -e PROJECT_VERSION_PATCH=$PROJECT_VERSION_PATCH \
        conan-builder bash -c \
        "cd /workspace && conan create . --build=missing -s build_type=$BUILD_TYPE"
else
    conan create . --build=missing -s build_type=$BUILD_TYPE
fi

echo "Build completed!"