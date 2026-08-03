#!/bin/bash
# ============================================================
# Очистка каталогов сборки
# ============================================================
# Использование:
#   ./scripts/clean.sh [--distro D] [--arch A] [--local]   # один вариант
#   ./scripts/clean.sh --all                               # весь build/
#   ./scripts/clean.sh --all --cache                       # + docker volumes с кэшем Conan
# ============================================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
parse_args "$@"

ALL=0; CACHE=0
for a in "${EXTRA_ARGS[@]}"; do
    case "$a" in
        --all) ALL=1 ;;
        --cache) CACHE=1 ;;
    esac
done

cd "$PROJECT_DIR"
if [ $ALL -eq 1 ]; then
    log "Удаление build/"
    rm -rf build CMakeUserPresets.json
    if [ $CACHE -eq 1 ]; then
        log "Удаление docker volumes ${PROJECT_NAME}-conan-*"
        docker volume ls -q --filter "name=^${PROJECT_NAME}-conan-" | xargs -r docker volume rm
    fi
else
    log "Удаление ${BUILD_ROOT}/{Debug,Release,...}"
    rm -rf "${BUILD_ROOT:?}"/{Debug,Release,RelWithDebInfo,MinSizeRel}
    if [ $CACHE -eq 1 ] && [ "$MODE" = "docker" ]; then
        docker volume rm "${PROJECT_NAME}-conan-${VARIANT}" || true
    fi
fi
