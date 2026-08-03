# Conan + VSCode + Docker Template

Шаблон C++20-проекта для удобной разработки:

- **Conan 2** — зависимости (fmt, Boost, OpenSSL; опционально PostgreSQL, ctre, spdlog);
- **CMake** — сборка, предупреждения, санитайзеры в Debug, GoogleTest;
- **Docker** — воспроизводимая сборка под разные **дистрибутивы и архитектуры**;
- **VS Code** — devcontainer, задачи, отладка gdb (F5), clangd + clang-tidy;
- **GitHub Actions** — та же матрица сборок в CI.

## Быстрый старт

```bash
git clone --recursive <url>
cd conan-vscode-docker-template

./scripts/build.sh          # сборка Debug в Docker (вариант из .env)
./scripts/test.sh           # сборка + модульные тесты
./scripts/run.sh -- --help  # сборка + запуск программы с аргументами
```

Нужен только Docker. Первая сборка долгая (Conan собирает Boost/OpenSSL), дальше всё берётся из кэша.

Результат: `build/<distro>-<arch>/<Type>/bin/<PROJECT_NAME>-<version>`, например
`build/ubuntu-24.04-arm64/Debug/bin/my_app-0.1.0`.

## Варианты сборки

Вариант = **дистрибутив × архитектура × тип сборки**. У каждого варианта свой образ,
свой каталог `build/<distro>-<arch>/` и свой кэш Conan — варианты не мешают друг другу.

| Параметр | Значения | По умолчанию |
|---|---|---|
| `--distro` | файлы `docker/variants/*.env`: `ubuntu-24.04`, `debian-12` | `DISTRO` из `.env` |
| `--arch` | `amd64`, `arm64`, `native` | `ARCH` из `.env` (пусто = как у хоста) |
| `--type` | `Debug`, `Release` | `Debug` |
| `--local` | сборка на хосте без Docker | — |

```bash
./scripts/build.sh --distro debian-12 --type Release
./scripts/build.sh --arch amd64                       # x86_64 на Mac с Apple Silicon (эмуляция)
./scripts/matrix.sh                                   # все дистрибутивы × Debug,Release + тесты
./scripts/matrix.sh --arches "arm64 amd64" --types Release
```

Чужая архитектура собирается через эмуляцию (`docker --platform`, Rosetta/QEMU) — это
медленнее в разы, но только при первой сборке зависимостей.

### Сменить образ / добавить дистрибутив

1. Создайте `docker/variants/<имя>.env`:
   ```bash
   BASE_IMAGE=ubuntu:22.04
   ```
2. Используйте: `./scripts/build.sh --distro <имя>`.
3. По желанию: добавьте имя в `.github/workflows/ci.yml` (`matrix.distro`),
   `.vscode/tasks.json` (`inputs` → `distro`) и скопируйте `.devcontainer/<distro>/`.

Подробнее — [docker/variants/README.md](docker/variants/README.md).

Вариант по умолчанию меняется в `.env` (`DISTRO=`, `ARCH=`).

### Добавить системные пакеты

- постоянно — строка в [docker/packages.extra.txt](docker/packages.extra.txt);
- разово — `EXTRA_PACKAGES="valgrind lcov" ./scripts/build.sh`.

Образ пересобирается автоматически при следующем запуске скриптов (слои кэшируются).

### Добавить C++-зависимость

**Из Conan Center** (предпочтительно): в `conanfile.py` → `requirements()`,
затем `find_package` в `CMakeLists.txt` и добавить таргет в `EXTERNAL_LIBRARIES`.

**Из исходников (git-сабмодуль)** — если библиотеки нет в Conan или нужен конкретный коммит/форк:

```bash
git submodule add https://github.com/<owner>/<lib>.git libraries/<lib>
git -C libraries/<lib> checkout v1.2.3      # закрепить версию
git add .gitmodules libraries/<lib>
```

и подключить в [libraries/CMakeLists.txt](libraries/CMakeLists.txt):

```cmake
add_subdirectory(<lib> EXCLUDE_FROM_ALL)
list(APPEND _libraries <lib>::<target>)
```

Таргеты из `_libraries` автоматически линкуются к коду проекта. Там же описано,
как обновить/удалить сабмодуль и как настроить чужой CMake (опции, `-Werror`, `WHOLE_ARCHIVE`).
Скрипты, devcontainer и CI сами выполняют `git submodule update --init --recursive`.

Встроенные опциональные зависимости включаются опциями Conan:

```bash
./scripts/build.sh -o "&:with_postgres=True" -o "&:with_spdlog=True"
```

| Опция | Что подключает | По умолчанию |
|---|---|---|
| `with_tests` | GoogleTest, каталог `tests/` | `True` |
| `with_postgres` | libpq, libpqxx | `False` |
| `with_ctre` | ctre | `False` |
| `with_spdlog` | spdlog | `False` |

## Скрипты

| Скрипт | Назначение |
|---|---|
| `scripts/build.sh` | сборка (Conan install + CMake build) |
| `scripts/test.sh` | сборка + `ctest` (аргументы ctest после `--`) |
| `scripts/run.sh` | сборка + запуск (аргументы программы после `--`) |
| `scripts/matrix.sh` | сборка + тесты по матрице вариантов, итоговая таблица |
| `scripts/shell.sh` | интерактивная оболочка в контейнере варианта (gdb, conan…) |
| `scripts/exec.sh` | одна команда в контейнере: `./scripts/exec.sh -- conan list "*"` |
| `scripts/format.sh` | clang-format (`--check` — только проверка) |
| `scripts/tidy.sh` | clang-tidy по `src/` и `tests/` |
| `scripts/clean.sh` | очистка варианта; `--all` — весь `build/`; `--cache` — + кэш Conan |
| `scripts/setup.sh` | первичная настройка внутри контейнера (вызывается devcontainer) |

Все скрипты принимают общие параметры `--distro/--arch/--type/--local`.
Внутри контейнера они автоматически работают локально.

## VS Code

### Dev Container (рекомендуется)

1. Установите расширение **Dev Containers**.
2. `Cmd/Ctrl+Shift+P` → **Dev Containers: Reopen in Container** → выберите
   **C++ (Ubuntu 24.04)** или **C++ (Debian 12)**.
3. После первого запуска `scripts/setup.sh` подтянет сабмодули и зависимости Conan
   для Debug и Release, создаст пресеты CMake и `compile_commands.json` для clangd.
4. В строке состояния CMake Tools выберите пресет **conan-debug**.

### Отладка (F5)

Внутри dev-контейнера, вкладка Run and Debug:

- **Debug: программа (gdb)** — собирает текущий пресет и запускает выбранный launch-таргет;
- **Debug: тесты (gdb)** — `unit_tests` (фильтр — `--gtest_filter=...` в `args`).

Debug-сборка включает **AddressSanitizer + UndefinedBehaviorSanitizer**; при ошибке
gdb останавливается в месте её возникновения. Отключить: `-DENABLE_SANITIZERS=OFF`.

С хоста можно отлаживать в консоли: `./scripts/shell.sh`, затем
`gdb ./build/Debug/bin/my_app-0.1.0`.

### Задачи (Terminal → Run Task)

`Build`, `Build Release`, `Test`, `Run`, `Matrix`, `Format`, `Clang-tidy`, `Clean`, а также
варианты с «…» — с выбором дистрибутива, архитектуры и типа сборки.

## Тесты

GoogleTest подключён через Conan (`with_tests=True`). Примеры:

- [tests/sample_test.cpp](tests/sample_test.cpp) — минимальный тест;
- [tests/program_args_test.cpp](tests/program_args_test.cpp) — тесты разбора аргументов командной строки
  (`args::ProgramOptions`): значения по умолчанию, `--opt value` и `--opt=value`, неизвестная опция,
  опция без значения, `--help` с перехватом stdout.

Новый тест: создайте `tests/<name>_test.cpp` и добавьте его в `add_executable(unit_tests ...)`
в [tests/CMakeLists.txt](tests/CMakeLists.txt). Код проекта доступен через `module_src`.

```bash
./scripts/test.sh
./scripts/test.sh -- -R SampleTest -V
```

## Качество кода

- [.clang-format](.clang-format) — стиль (на основе LLVM): `./scripts/format.sh`, проверка `--check`;
- [.clang-tidy](.clang-tidy) — статический анализ: в редакторе через clangd, полный прогон `./scripts/tidy.sh`,
  при компиляции — `-DENABLE_CLANG_TIDY=ON`;
- [cmake/CompilerWarnings.cmake](cmake/CompilerWarnings.cmake) — предупреждения для кода проекта,
  `-DWARNINGS_AS_ERRORS=ON` превращает их в ошибки;
- [cmake/Sanitizers.cmake](cmake/Sanitizers.cmake) — ASan/UBSan, по умолчанию в Debug.

## CI (GitHub Actions)

[.github/workflows/ci.yml](.github/workflows/ci.yml) на каждый push/PR в `main`/`develop`:

- собирает и тестирует матрицу `ubuntu-24.04, debian-12 × Debug, Release` (amd64)
  теми же скриптами и образами, что и локально;
- кэширует пакеты Conan между запусками;
- сохраняет Release-бинарники как артефакты;
- проверяет форматирование.

Сборку под arm64 на нативных ARM-раннерах GitHub можно включить, раскомментировав
блок `include` в матрице.

## Структура проекта

```
├── src/                     # исходники (module_src + main.cpp)
├── tests/                   # GoogleTest
├── libraries/               # сторонний код из исходников (git-сабмодули)
├── cmake/                   # project-config, предупреждения, санитайзеры, clang-tidy
├── docker/
│   ├── Dockerfile           # параметризуемый образ (BASE_IMAGE, CONAN_VERSION, EXTRA_PACKAGES)
│   ├── packages.txt         # базовые apt-пакеты
│   ├── packages.extra.txt   # пакеты вашего проекта
│   └── variants/            # дистрибутивы: <distro>.env
├── scripts/                 # build/test/run/matrix/shell/exec/format/tidy/clean/setup
├── .devcontainer/           # dev-контейнеры по дистрибутивам
├── .vscode/                 # задачи, отладка, настройки
├── .github/workflows/ci.yml
├── conanfile.py
├── CMakeLists.txt
├── docker-compose.yml
├── project-config.sh        # имя/версия для shell
└── .env                     # имя, версия, вариант сборки по умолчанию
```

Имя и версия проекта задаются в `.env` (`PROJECT_NAME`, `PROJECT_VERSION_*`);
бинарник называется `<PROJECT_NAME>-<major>.<minor>.<patch>`.

## Troubleshooting

- **Каталог сабмодуля в `libraries/` пустой** — `git submodule update --init --recursive`
  (скрипты делают это автоматически).
- **Сломался кэш CMake / странные ошибки после смены компилятора** — `./scripts/clean.sh`.
- **Сломался кэш Conan варианта** — `./scripts/clean.sh --cache`.
- **LeakSanitizer: «does not work under ptrace»** — под gdb утечки не проверяются
  (`detect_leaks=0` в launch.json); запустите `./scripts/test.sh` / `./scripts/run.sh`.

## Лицензия

MIT
