# Conan + VSCode + Docker Template

Полный шаблон проекта для разработки C++ приложений с использованием:
- **Conan** - менеджер зависимостей
- **VSCode** - редактор кода
- **Docker** - контейнеризация
- **CMake** - система сборки

## Структура проекта

```
conan-vscode-docker-template/
├── src/                       # Исходные файлы C++
│   ├── main.cpp
│   └── hello.cpp
├── include/                    # Заголовочные файлы
│   └── hello.h
├── build/                      # Папка сборки (auto-generated)
├── scripts/                    # Вспомогательные скрипты
│   ├── build.sh
│   └── run.sh
├── .vscode/                    # VSCode конфигурация
│   ├── tasks.json              # Tasks для сборки и запуска
│   ├── launch.json             # Debug конфигурация
│   └── settings.json           # VSCode settings
├── .devcontainer/              # Dev container конфигурация
│   └── devcontainer.json
├── .github/workflows/          # CI/CD workflows
│   └── ci.yml
├── conanfile.py                # Conan манифест
├── CMakeLists.txt              # CMake конфигурация
├── Dockerfile                  # Docker образ
├── docker-compose.yml          # Docker Compose конфигурация
├── .gitignore
└── README.md
```

## Быстрый старт

### 1. Локальная сборка (без Docker)

```bash
# Обнаружение профиля Conan
conan profile detect --force

# Build Release
conan create . --build=missing -s build_type=Release

# Build Debug
conan create . --build=missing -s build_type=Debug
```

### 2. Сборка в Docker

```bash
# Build Docker образа
docker build -t conan-builder .

# Build Release в Docker
docker run --rm -v $(pwd):/workspace conan-builder bash -c 'cd /workspace && conan create . --build=missing -s build_type=Release'

# Build Debug в Docker
docker run --rm -v $(pwd):/workspace conan-builder bash -c 'cd /workspace && conan create . --build=missing -s build_type=Debug'
```

### 3. Использование scripts

```bash
# Сделать скрипты исполняемыми
chmod +x scripts/build.sh scripts/run.sh

# Build Release локально
./scripts/build.sh Release local

# Build Release в Docker
./scripts/build.sh Release docker

# Запуск Release локально
./scripts/run.sh Release local

# Запуск Release в Docker
./scripts/run.sh Release docker
```

## VSCode Tasks

Нажмите `Ctrl+Shift+P` (или `Cmd+Shift+P` на Mac) и выберите "Run Task":

### Build Tasks
- **Build Release** - Локальная сборка Release версии
- **Build Debug** - Локальная сборка Debug версии
- **Build Release (Docker)** - Сборка в Docker контейнере (Release)

### Run Tasks
- **Run (Local Release)** - Запуск собранного Release приложения локально
- **Run (Docker Release)** - Запуск приложения в Docker контейнере

### Debug Tasks
- **Launch (GDB Local Debug)** - Запуск отладчика GDB локально
- **Launch (GDB Docker Debug)** - Запуск отладчика в Docker

### Utility Tasks
- **Clean Build** - Удаление всех артефактов сборки

## VSCode Debug (F5)

Нажмите `F5` или перейдите в Debug (Ctrl+Shift+D) и выберите:

- **Launch (GDB Local Debug)** - Отладка Debug версии с GDB
- **Run (Local Release)** - Запуск Release версии

## Поддерживаемые архитектуры

Шаблон поддерживает различные архитектуры через Conan профили:

```bash
# x86_64
conan create . -s arch=x86_64

# ARM64
conan create . -s arch=armv8

# ARM32
conan create . -s arch=armv7
```

## Поддерживаемые ОС

- Linux (GNU, Clang)
- macOS (Apple Clang)
- Windows (MSVC, MinGW)

## Dev Container (Remote Development)

Если вы используете VSCode Remote Containers:

1. Установите расширение "Dev Containers" в VSCode
2. Откройте палитру команд: `Ctrl+Shift+P`
3. Выберите "Dev Containers: Reopen in Container"
4. VSCode перезагрузится внутри контейнера
5. Все задачи и отладка будут работать внутри контейнера

## Расширение шаблона

### Добавление новых зависимостей

Отредактируйте `conanfile.py`:

```python
def requirements(self):
    self.requires("zlib/1.2.13")
    self.requires("openssl/3.1.0")
```

### Добавление новых исходных файлов

Добавьте `.cpp` файлы в папку `src/` и `.h` файлы в папку `include/`. CMakeLists.txt автоматически найдет все файлы.

### Кастомизация Docker образа

Отредактируйте `Dockerfile` для добавления инструментов:

```dockerfile
RUN apt-get install -y git valgrind ninja-build
```

## Troubleshooting

### CMakeLists.txt не найден

Убедитесь, что `CMakeLists.txt` находится в корне проекта.

### Docker контейнер не найден

```bash
docker build -t conan-builder .
```

### Проблемы с профилем Conan

```bash
conan profile detect --force
conan profile show
```

### Ошибка при сборке в Docker

Убедитесь, что Docker запущен:

```bash
docker ps
```

### Проблемы с правами доступа к скриптам

```bash
chmod +x scripts/*.sh
```

## GitHub Actions CI/CD

Шаблон включает GitHub Actions workflow (`.github/workflows/ci.yml`), который:
- Запускается при push в main/develop и PR в main
- Собирает проект для Release и Debug конфигураций
- Поддерживает x86_64 и armv8 архитектуры
- Запускает собранное приложение

## Лицензия

MIT