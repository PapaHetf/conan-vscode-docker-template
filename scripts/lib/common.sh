#!/bin/bash
# ============================================================
# Общая логика скриптов: разбор аргументов, вариант сборки, запуск в Docker.
# Подключается через:  source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
# ============================================================
#
# Общие параметры всех скриптов:
#   --distro <name>   дистрибутив из docker/variants/ (по умолчанию DISTRO из .env)
#   --arch <arch>     amd64 | arm64 | native (по умолчанию ARCH из .env, пусто = native)
#   --type <type>     Debug | Release (по умолчанию Debug)
#   --local           собирать на хосте, без Docker
#   -- <args...>      всё после "--" передаётся программе (run.sh)
#
# Внутри контейнера (devcontainer или docker compose) скрипты всегда работают
# локально — Docker внутри Docker не нужен.
# ============================================================

set -eo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Имя/версия проекта и значения из .env (DISTRO, ARCH, ...)
# shellcheck source=../../project-config.sh
source "${PROJECT_DIR}/project-config.sh"

BUILD_TYPE="Debug"
MODE="docker"
PROGRAM_ARGS=()
EXTRA_ARGS=()
DISTRO="${DISTRO:-ubuntu-24.04}"
ARCH="${ARCH:-}"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

in_container() {
    [ -f /.dockerenv ] || [ -n "${REMOTE_CONTAINERS:-}" ] || [ -n "${CODESPACES:-}" ]
}

# Архитектура хоста в терминах Docker: amd64 | arm64
host_arch() {
    case "$(uname -m)" in
        x86_64|amd64)  echo amd64 ;;
        arm64|aarch64) echo arm64 ;;
        *) die "Неизвестная архитектура хоста: $(uname -m)" ;;
    esac
}

# Список доступных дистрибутивов (имена файлов docker/variants/*.env)
list_distros() {
    local f
    for f in "${PROJECT_DIR}"/docker/variants/*.env; do
        basename "$f" .env
    done
}

# Разбор общих аргументов. Неизвестные аргументы складываются в EXTRA_ARGS.
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --distro) DISTRO="$2"; shift 2 ;;
            --arch)   ARCH="$2"; shift 2 ;;
            --type)   BUILD_TYPE="$2"; shift 2 ;;
            --local)  MODE="local"; shift ;;
            --docker) MODE="docker"; shift ;;
            --) shift; PROGRAM_ARGS=("$@"); break ;;
            *) EXTRA_ARGS+=("$1"); shift ;;
        esac
    done

    case "$BUILD_TYPE" in
        Debug|Release|RelWithDebInfo|MinSizeRel) ;;
        debug) BUILD_TYPE=Debug ;;
        release) BUILD_TYPE=Release ;;
        *) die "Неизвестный тип сборки: $BUILD_TYPE" ;;
    esac

    if in_container; then
        MODE="local"
    fi

    resolve_variant
}

# Вычисляет параметры варианта и экспортирует их для docker compose
resolve_variant() {
    if [ -z "$ARCH" ] || [ "$ARCH" = "native" ]; then
        ARCH="$(host_arch)"
    fi
    case "$ARCH" in
        amd64|arm64) ;;
        x86_64) ARCH=amd64 ;;
        aarch64|armv8) ARCH=arm64 ;;
        *) die "Неподдерживаемая архитектура: $ARCH (amd64 | arm64)" ;;
    esac

    if [ "$MODE" = "docker" ]; then
        local variant_file="${PROJECT_DIR}/docker/variants/${DISTRO}.env"
        [ -f "$variant_file" ] || die "Нет варианта '${DISTRO}'. Доступны: $(list_distros | tr '\n' ' ')"
        # shellcheck disable=SC1090
        BASE_IMAGE="$(set -a; source "$variant_file"; echo "$BASE_IMAGE")"

        export VARIANT="${DISTRO}-${ARCH}"
        export BASE_IMAGE
        export DOCKER_DEFAULT_PLATFORM="linux/${ARCH}"
        export COMPOSE_PROJECT_NAME="${PROJECT_NAME}-${VARIANT//./-}"
        BUILD_ROOT="build/${VARIANT}"
        mkdir -p "${PROJECT_DIR}/${BUILD_ROOT}"

        if [ "$ARCH" != "$(host_arch)" ]; then
            warn "Архитектура ${ARCH} отличается от хоста ($(host_arch)) — сборка через эмуляцию, будет медленнее."
        fi
    else
        BUILD_ROOT="build"
    fi
}

# Описание текущего варианта для логов
describe() {
    if [ "$MODE" = "docker" ]; then
        echo "${PROJECT_NAME} ${PROJECT_VERSION_STRING} | ${VARIANT} (${BASE_IMAGE}) | ${BUILD_TYPE}"
    else
        echo "${PROJECT_NAME} ${PROJECT_VERSION_STRING} | local | ${BUILD_TYPE}"
    fi
}

# Выполнить команду в окружении сборки (контейнер варианта или хост).
#   in_env "<shell command>"            — без TTY
#   IN_ENV_TTY=1 in_env "<command>"     — интерактивно
# Путь к каталогу сборки внутри окружения всегда build/<Type>.
in_env() {
    local cmd="$1"
    if [ "$MODE" = "docker" ]; then
        command -v docker >/dev/null || die "docker не найден. Используйте --local или установите Docker."
        local tty_flag="-T"
        if [ "${IN_ENV_TTY:-0}" = "1" ] && [ -t 0 ]; then
            tty_flag=""
        fi
        (
            cd "$PROJECT_DIR"
            # Пересобрать образ, если изменились Dockerfile / списки пакетов (слои кэшируются).
            # DOCKER_BUILD_VERBOSE=1 — показать ход сборки образа.
            if [ "${DOCKER_BUILD_VERBOSE:-0}" = "1" ]; then
                docker compose build builder
            else
                log "Подготовка образа ${PROJECT_NAME}-dev:${VARIANT}…"
                docker compose build --quiet builder >/dev/null
            fi
            docker compose run --rm ${tty_flag} builder bash -c "$cmd"
        )
    else
        if [ -f "${PROJECT_DIR}/.venv/bin/activate" ] && ! in_container; then
            # shellcheck disable=SC1091
            source "${PROJECT_DIR}/.venv/bin/activate"
        fi
        (cd "$PROJECT_DIR" && bash -c "$cmd")
    fi
}

# Подготовка окружения: сабмодули + профиль Conan
PREPARE_CMD='git config --global --add safe.directory "*" 2>/dev/null || true; \
[ ! -f .gitmodules ] || git submodule update --init --recursive; \
conan profile detect --exist-ok >/dev/null 2>&1 || true'

# Команда сборки через Conan (install + build) для BUILD_TYPE
conan_build_cmd() {
    local extra="${1:-}"
    echo "${PREPARE_CMD}; conan build . --build=missing -s build_type=${BUILD_TYPE} -c tools.build:skip_test=True ${extra}"
}

# Безопасно склеить массив аргументов в строку для bash -c
quote_args() {
    local out="" a
    for a in "$@"; do
        out+=" $(printf '%q' "$a")"
    done
    echo "$out"
}
