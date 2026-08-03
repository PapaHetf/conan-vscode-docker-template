FROM ubuntu:24.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    gdb \
    git \
    clangd-14 \
    clang-14 \
    libclang-14-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем clangd и clang как версию по умолчанию
RUN update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-14 100 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-14 100

# Настраиваем пути для pipx и устанавливаем conan глобально
ENV PIPX_BIN_DIR=/usr/local/bin
ENV PIPX_HOME=/opt/pipx
RUN pipx install conan

# Детектим профиль Conan
RUN conan profile detect --force

WORKDIR /workspace

CMD ["/bin/bash"]
