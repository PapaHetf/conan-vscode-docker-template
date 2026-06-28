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
    && rm -rf /var/lib/apt/lists/*

RUN pip install conan

RUN conan profile detect --force

WORKDIR /workspace

CMD ["/bin/bash"]