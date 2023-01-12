# TODO - To save space in this docker image, consider adding the specific dependencies to this
#        dockerfile that would be needed to run psinode/psibase. Then simply using ubuntu:20.04
#        as the parent image, rather than pulling in the entire development environment.

FROM ghcr.io/gofractally/psibase-ubuntu-2004-builder:latest

RUN mkdir -p \
    /root/deps \
    /root/psinode

# Install deps
RUN export DEBIAN_FRONTEND=noninteractive   \
    && apt-get update                       \
    && apt-get install -yq                  \
        curl                                \
        wget                                \
        xz-utils                            \
    && apt-get clean -yq                    \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/deps

# Psidk
RUN wget https://github.com/gofractally/psibase/releases/download/rolling-release/psidk-ubuntu-2004.tar.gz \
    && tar xf psidk-ubuntu-2004.tar.gz         \
    && rm psidk-ubuntu-2004.tar.gz
ENV PSIDK_PREFIX=/root/deps/psidk-ubuntu-2004
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
