FROM ghcr.io/gofractally/psibase-ubuntu-2004-builder:latest as base

# Remove unneeded items from the image
RUN cd /opt && rm -rf                                   \
        cargo                                           \
        clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04 \
        rustup                                          \
        node-v16.17.0-linux-x64                         \
        wasi-sdk-14.0                                   \
    && cd /usr/local/bin && rm                          \
        ccache                                          \
    && rm /usr/local/lib/libboost*

# Install deps
RUN export DEBIAN_FRONTEND=noninteractive   \
    && apt-get update                       \
    && apt-get install -yq                  \
        supervisor                          \
        wget                                \
        xz-utils                            \
    && apt-get clean -yq                    \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# Psidk
RUN wget https://github.com/gofractally/psibase/releases/download/rolling-release/psidk-ubuntu-2004.tar.gz \
    && tar xf psidk-ubuntu-2004.tar.gz          \
    && rm psidk-ubuntu-2004.tar.gz              \
    && cd /opt/psidk-ubuntu-2004/bin            \
    && rm psidk-cmake-args psitest

# Configure supervisor with psinode
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /root/psinode

# Add some tools
ADD scripts /usr/local/bin/
RUN chmod -R 0700 /usr/local/bin/

# Squash layers
FROM ubuntu:focal
COPY --from=base / /

ENV PSIDK_HOME=/opt/psidk-ubuntu-2004
ENV PATH=$PSIDK_HOME/bin:$PATH

LABEL org.opencontainers.image.title="Psinode_Ubuntu-20.04" \
    org.opencontainers.image.description="This docker image uses supervisord to automatically manage a psinode process." \
    org.opencontainers.image.vendor="Fractally LLC" \
    org.opencontainers.image.url="https://github.com/gofractally/psinode-docker-image" \
    org.opencontainers.image.documentation="https://doc-sys.psibase.io/psibase/index.html"

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
