#!/bin/bash
# ============================================================
# Выполнить произвольную команду в окружении сборки варианта
# ============================================================
# Использование:
#   ./scripts/exec.sh [--distro D] [--arch A] -- <команда...>
#
# Примеры:
#   ./scripts/exec.sh -- conan list "*"
#   ./scripts/exec.sh --distro debian-12 -- gcc --version
# ============================================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
parse_args "$@"

[ ${#PROGRAM_ARGS[@]} -gt 0 ] || die "Укажите команду после --"
in_env "${PREPARE_CMD}; $(quote_args "${PROGRAM_ARGS[@]}")"
