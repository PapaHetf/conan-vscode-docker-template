#!/bin/bash
# ============================================================
# Сборка + тесты по матрице вариантов: дистрибутивы × архитектуры × типы
# ============================================================
# Использование:
#   ./scripts/matrix.sh [--distros "a b"] [--arches "amd64 arm64"] [--types "Debug Release"]
#
# По умолчанию: все docker/variants/*.env × архитектура хоста × Debug,Release.
#
# Примеры:
#   ./scripts/matrix.sh
#   ./scripts/matrix.sh --arches "arm64 amd64" --types Release
#   ./scripts/matrix.sh --distros debian-12
# ============================================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

DISTROS="$(list_distros | tr '\n' ' ')"
ARCHES="$(host_arch)"
TYPES="Debug Release"

while [ $# -gt 0 ]; do
    case "$1" in
        --distros) DISTROS="$2"; shift 2 ;;
        --arches)  ARCHES="$2"; shift 2 ;;
        --types)   TYPES="$2"; shift 2 ;;
        *) die "Неизвестный аргумент: $1" ;;
    esac
done

in_container && die "matrix.sh запускается с хоста (нужен Docker)."

RESULTS=()
FAILED=0
for distro in $DISTROS; do
    for arch in $ARCHES; do
        for type in $TYPES; do
            name="${distro}-${arch} ${type}"
            log "[$name]"
            start=$(date +%s)
            if "${PROJECT_DIR}/scripts/test.sh" --distro "$distro" --arch "$arch" --type "$type"; then
                status="OK"
            else
                status="FAIL"; FAILED=1
            fi
            RESULTS+=("$(printf '%-28s %-5s %5ss' "$name" "$status" "$(( $(date +%s) - start ))")")
        done
    done
done

echo
log "Итог:"
printf '  %s\n' "${RESULTS[@]}"
exit $FAILED
