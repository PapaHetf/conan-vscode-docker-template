#!/bin/bash
# ============================================================
# Сборка и запуск модульных тестов (GoogleTest + ctest)
# ============================================================
# Использование:
#   ./scripts/test.sh [--distro D] [--arch A] [--type Debug|Release] [--local] [-- ctest-args]
#
# Примеры:
#   ./scripts/test.sh
#   ./scripts/test.sh --type Release
#   ./scripts/test.sh -- -R SampleTest -V              # фильтр и подробный вывод ctest
# ============================================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
parse_args "$@"

log "Тесты: $(describe)"
in_env "$(conan_build_cmd "-o '&:with_tests=True' $(quote_args "${EXTRA_ARGS[@]}")") && \
ctest --test-dir build/${BUILD_TYPE}/tests --output-on-failure$(quote_args "${PROGRAM_ARGS[@]}")"
