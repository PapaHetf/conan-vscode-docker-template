#!/bin/bash
# ============================================================
# Статический анализ clang-tidy по .clang-tidy
# ============================================================
# Использование:
#   ./scripts/tidy.sh [--distro D] [--arch A] [--local] [-- файлы...]
#
# Нужна база компиляции build/Debug/compile_commands.json —
# скрипт сам выполнит сборку Debug, если её нет.
# По умолчанию проверяются все .cpp проекта из базы компиляции (без libraries/).
# ============================================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
BUILD_TYPE=Debug
parse_args "$@"

FILES="$(quote_args "${PROGRAM_ARGS[@]}")"
if [ -z "$FILES" ]; then
    # Только файлы проекта, которые реально компилируются (есть в compile_commands.json)
    FILES="\$(python3 scripts/lib/project_sources.py build/${BUILD_TYPE}/compile_commands.json)"
fi

log "clang-tidy: $(describe)"
in_env "[ -f build/${BUILD_TYPE}/compile_commands.json ] || { $(conan_build_cmd); } && \
clang-tidy --version && \
clang-tidy -p build/${BUILD_TYPE} --quiet ${FILES}"
