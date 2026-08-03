# ============================================================
# Образ сборки/разработки. Базовый дистрибутив задаётся аргументом.
# ============================================================
#   BASE_IMAGE      — базовый образ (см. docker/variants/*.env)
#   CONAN_VERSION   — версия Conan 2
#   EXTRA_PACKAGES  — доп. apt-пакеты через пробел (разово, без правки файлов)
#
# Постоянные списки пакетов:
#   docker/packages.txt        — базовые пакеты шаблона
#   docker/packages.extra.txt  — пакеты вашего проекта
#
# Обычно образ собирается скриптами (./scripts/build.sh ...) или devcontainer.
# Вручную:
#   docker build -f docker/Dockerfile --build-arg BASE_IMAGE=debian:12 .
# ============================================================
ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

ARG CONAN_VERSION=2.29.1
ARG EXTRA_PACKAGES=""

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Пакеты: строки-комментарии (#) и пустые строки пропускаются
COPY docker/packages.txt docker/packages.extra.txt /tmp/packages/
RUN set -eux; \
    packages="$(cat /tmp/packages/*.txt | sed 's/#.*//' | tr -s ' \t\r\n' ' ') ${EXTRA_PACKAGES}"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ${packages}; \
    rm -rf /var/lib/apt/lists/* /tmp/packages

# Conan ставится через pipx в изолированное окружение
ENV PIPX_BIN_DIR=/usr/local/bin \
    PIPX_HOME=/opt/pipx
RUN pipx install "conan==${CONAN_VERSION}" && conan --version

# Профиль Conan определяется при первом запуске (scripts/setup.sh):
# ~/.conan2 монтируется отдельным volume для каждого варианта сборки.

WORKDIR /workspace
CMD ["/bin/bash"]
