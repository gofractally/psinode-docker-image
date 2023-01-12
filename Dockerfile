FROM ubuntu:20.04

RUN mkdir -p \
    /root/deps \
    /root/psinode

# Install deps
RUN export DEBIAN_FRONTEND=noninteractive   \
    && apt-get update                       \
    && apt-get install -yq                  \
        curl                                \
        wget                                \
    && apt-get clean -yq                    \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/deps

# Psidk
RUN wget https://github.com/gofractally/psibase/releases/download/rolling-release/psidk-linux.tar.gz \
    && tar xf psidk-linux.tar.gz         \
    && rm psidk-linux.tar.gz
ENV PSIDK_PREFIX=/root/deps/psidk
ENV PATH=$PSIDK_PREFIX/bin:$PATH

# Install deps
RUN export DEBIAN_FRONTEND=noninteractive    \
    && apt-get update                        \
    && apt-get install -yq                   \
        supervisor                           \
    && apt-get clean -yq                     \
    && rm -rf /var/lib/apt/lists/*

# Configure supervisor with psinode
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add some tools
ADD scripts /root/psinode/scripts
ENV PATH=/root/psinode/scripts:$PATH
RUN chmod -R 0700 /root/psinode/scripts/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
