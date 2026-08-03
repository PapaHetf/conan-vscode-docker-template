#!/bin/bash
# ============================================================
# Интерактивная оболочка в контейнере варианта (gdb, conan, cmake и т.д.)
# ============================================================
# Использование:
#   ./scripts/shell.sh [--distro D] [--arch A]
#
# Внутри: каталог сборки — build/<Type>, программа — build/<Type>/bin/<name>-<version>
#   gdb ./build/Debug/bin/${TARGET_NAME}
# ============================================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
parse_args "$@"

[ "$MODE" = "docker" ] || die "shell.sh предназначен для запуска с хоста (Docker)."

log "Оболочка: ${VARIANT} (${BASE_IMAGE})"
IN_ENV_TTY=1 in_env "${PREPARE_CMD}; exec bash"
