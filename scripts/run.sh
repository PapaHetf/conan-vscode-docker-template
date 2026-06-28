#!/bin/bash

# Run script for Conan project
# Usage: ./scripts/run.sh [Release|Debug] [local|docker]

BUILD_TYPE=${1:-Release}
BUILD_ENV=${2:-local}

echo "Running $BUILD_TYPE configuration..."

if [ "$BUILD_ENV" = "docker" ]; then
    docker run --rm -v $(pwd):/workspace conan-builder bash -c "cd /workspace && conan build . -s build_type=$BUILD_TYPE && ./build/$BUILD_TYPE/bin/ex_conan_app"
else
    conan build . -s build_type=$BUILD_TYPE
    ./build/$BUILD_TYPE/bin/ex_conan_app
fi