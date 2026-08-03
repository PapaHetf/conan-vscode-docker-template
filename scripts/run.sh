#!/bin/bash
# ============================================================
# Сборка и запуск программы
# ============================================================
# Использование:
#   ./scripts/run.sh [--distro D] [--arch A] [--type Debug|Release] [--local] [-- args...]
#
# Примеры:
#   ./scripts/run.sh -- --help
#   ./scripts/run.sh --type Release -- --path ./data --password secret
#   ./scripts/run.sh --distro debian-12 -- --help
# ============================================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
parse_args "$@"

log "Запуск: $(describe)"
if [ ${#PROGRAM_ARGS[@]} -gt 0 ]; then
    log "Аргументы: ${PROGRAM_ARGS[*]}"
fi
IN_ENV_TTY=1 in_env "$(conan_build_cmd "$(quote_args "${EXTRA_ARGS[@]}")") && \
./build/${BUILD_TYPE}/bin/${TARGET_NAME}$(quote_args "${PROGRAM_ARGS[@]}")"
