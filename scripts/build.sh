#!/bin/bash

# Build script for Conan project
# Usage: ./scripts/build.sh [Release|Debug] [local|docker]

BUILD_TYPE=${1:-Release}
BUILD_ENV=${2:-local}

echo "Building $BUILD_TYPE configuration in $BUILD_ENV environment..."

if [ "$BUILD_ENV" = "docker" ]; then
    docker build -t conan-builder .
    docker run --rm -v $(pwd):/workspace conan-builder bash -c "cd /workspace && conan create . --build=missing -s build_type=$BUILD_TYPE"
else
    conan create . --build=missing -s build_type=$BUILD_TYPE
fi

echo "Build completed!"