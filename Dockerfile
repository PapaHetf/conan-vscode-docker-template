FROM ubuntu:22.04
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3 \
    python3-pip \
    python3-venv \
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

RUN pip install conan

RUN conan profile detect --force

WORKDIR /workspace

CMD ["/bin/bash"]