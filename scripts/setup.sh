#!/bin/bash
# ============================================================
# Первичная настройка окружения внутри контейнера (devcontainer postCreate)
# или на хосте: сабмодули, профиль Conan, зависимости для Debug и Release.
# После неё CMake Tools / clangd в VS Code сразу видят пресеты и compile_commands.json.
# ============================================================
# Использование:
#   ./scripts/setup.sh [conan-args...]
# ============================================================

set -eo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"
source ./project-config.sh

git config --global --add safe.directory '*' 2>/dev/null || true
git submodule update --init --recursive

conan profile detect --exist-ok

for type in Debug Release; do
    echo "==> conan install ($type)"
    conan install . --build=missing -s build_type="$type" "$@"
done

# Конфигурируем Debug, чтобы сразу появился compile_commands.json для clangd
cmake --preset conan-debug >/dev/null
echo "==> Готово. Сборка: ./scripts/build.sh  |  Тесты: ./scripts/test.sh"
