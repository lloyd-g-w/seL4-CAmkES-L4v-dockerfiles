#
# Copyright 2020, Data61/CSIRO
#
# SPDX-License-Identifier: BSD-2-Clause
#

ARG USER_BASE_IMG=trustworthysystems/sel4
# hadolint ignore=DL3006
FROM $USER_BASE_IMG
ARG TARGETPLATFORM

# This dockerfile is a shim between the images from Dockerhub and the
# user.dockerfile.
# Add extra dependencies in here!

# For example, uncomment this to get cowsay on top of the sel4/camkes/l4v
# dependencies:

# hadolint ignore=DL3008,DL3009
RUN apt-get update -q \
    && apt-get install -y --no-install-recommends \
        cowsay \
        sudo \
        pkg-config \
        libssl-dev \
        curl \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install \
    --git https://github.com/vi/websocat.git \
    --features ssl

RUN cp /root/.cargo/bin/websocat /usr/local/bin/

RUN apt-get update && apt-get install -y \
    ca-certificates \
    gnupg \
    lsb-release \
    wget \
    curl \
    software-properties-common \
 && wget https://apt.llvm.org/llvm.sh \
 && chmod +x llvm.sh \
 && ./llvm.sh 14 \
 && apt-get install -y clang-14 lld-14

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 190 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-14 190 && \
    update-alternatives --set clang /usr/bin/clang-14 && \
    update-alternatives --set clang++ /usr/bin/clang++-14
