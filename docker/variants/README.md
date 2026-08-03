# Варианты сборки

Каждый `*.env` в этом каталоге — отдельный дистрибутив для сборки.
Имя файла без расширения используется как `--distro`:

```bash
./scripts/build.sh --distro debian-12 --type Release
```

## Добавить дистрибутив

Создайте файл `docker/variants/<имя>.env`:

```bash
BASE_IMAGE=ubuntu:22.04
```

Требования к базовому образу: Debian-подобный (apt), CMake >= 3.24 в репозитории
(или добавьте установку новее в `docker/Dockerfile`).

Вариант появится в `./scripts/matrix.sh`. Чтобы он был и в CI и в выпадающих
списках VS Code — добавьте имя в `.github/workflows/ci.yml` (`matrix.distro`)
и в `.vscode/tasks.json` (`inputs` → `distro`).
