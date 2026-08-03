#!/bin/bash
# ============================================================
# Форматирование кода по .clang-format
# ============================================================
# Использование:
#   ./scripts/format.sh [--check] [--local] [--distro D]
#     --check  только проверить (код возврата != 0, если нужно форматирование)
#
# Обрабатываются src/, include/, tests/ (libraries/ и build/ не трогаются).
# ============================================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
parse_args "$@"

FLAGS="-i"
for a in "${EXTRA_ARGS[@]}"; do
    [ "$a" = "--check" ] && FLAGS="--dry-run --Werror"
done

log "clang-format ${FLAGS}: $(describe)"
in_env "clang-format --version && \
find \$(ls -d src include tests 2>/dev/null) -type f \\( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' -o -name '*.cc' \\) -print0 \
| xargs -0 -r clang-format ${FLAGS}"
