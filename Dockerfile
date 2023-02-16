# TODO - To save space in this docker image, consider adding the specific dependencies to this
#        dockerfile that would be needed to run psinode/psibase. Then simply using ubuntu:20.04
#        as the parent image, rather than pulling in the entire development environment.

FROM ghcr.io/gofractally/psibase-ubuntu-2004-builder:latest

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
    && tar xf psidk-ubuntu-2004.tar.gz         \
    && rm psidk-ubuntu-2004.tar.gz
ENV PSIDK_HOME=/opt/psidk-ubuntu-2004
ENV PATH=$PSIDK_HOME/bin:$PATH

# Configure supervisor with psinode
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /root/psinode

# Add some tools
ADD scripts /usr/local/bin/
RUN chmod -R 0700 /usr/local/bin/

LABEL org.opencontainers.image.title="Psinode_Ubuntu-20.04" \
    org.opencontainers.image.description="This docker image uses supervisord to automatically manage a psinode process." \
    org.opencontainers.image.vendor="Fractally LLC" \
    org.opencontainers.image.url="https://github.com/gofractally/psinode-docker-image" \
    org.opencontainers.image.documentation="https://doc-sys.psibase.io/psibase/index.html"

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
