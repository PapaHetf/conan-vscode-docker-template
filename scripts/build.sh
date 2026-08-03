#!/bin/bash
# ============================================================
# Сборка проекта (Conan install + CMake build)
# ============================================================
# Использование:
#   ./scripts/build.sh [--distro D] [--arch A] [--type Debug|Release] [--local]
#
# Примеры:
#   ./scripts/build.sh                                  # вариант из .env, Debug, в Docker
#   ./scripts/build.sh --type Release
#   ./scripts/build.sh --distro debian-12 --arch amd64 --type Release
#   ./scripts/build.sh --local                          # на хосте, без Docker
#   ./scripts/build.sh -o "&:with_postgres=True"        # доп. аргументы передаются в conan
#
# Результат: build/<distro>-<arch>/<Type>/bin/<name>-<version>
#            (при --local: build/<Type>/bin/...)
# ============================================================

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
parse_args "$@"

log "Сборка: $(describe)"
in_env "$(conan_build_cmd "$(quote_args "${EXTRA_ARGS[@]}")")"
log "Готово: ${BUILD_ROOT}/${BUILD_TYPE}/bin/${TARGET_NAME}"
