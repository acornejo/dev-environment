FROM debian:latest as builder
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

COPY imagesetup.sh /tmp/imagesetup.sh
COPY requirements.txt /tmp/requirements.txt
RUN /tmp/imagesetup.sh && rm -f /tmp/imagesetup.sh /tmp/requirements.txt

FROM debian:latest as final
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Install some basic debian packages
# libreadline8 and libsqlite3-0 are python requirements
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends curl sudo vim git bzip2 xz-utils ca-certificates libreadline8 libsqlite3-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy various packages available on builder
COPY --from=builder /opt/code-server /opt/code-server
COPY --from=builder /opt/golang /opt/golang
COPY --from=builder /opt/nodejs /opt/nodejs
COPY --from=builder /opt/python /opt/python
RUN echo /opt/python/lib > /etc/ld.so.conf.d/python.conf && ldconfig

# Setup path for all users
RUN echo 'PATH=/opt/python/bin:/opt/golang/bin:/opt/nodejs/bin:$PATH' > /etc/profile.d/docker.sh && \
    echo 'export PATH' >> /etc/profile.d/docker.sh

# Add new non-root user and customize its environment
RUN adduser --gecos '' --disabled-password coder && \
    mkdir -p /etc/sudoers.d && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
USER 1000
ENV USER=coder
ENV HOME=/home/coder
WORKDIR $HOME
COPY usersetup.sh /tmp/usersetup.sh
RUN /tmp/usersetup.sh && sudo rm -f /tmp/usersetup.sh

# Run code server on port 8080
EXPOSE 8080
ENTRYPOINT exec /opt/code-server/bin/code-server --auth none --bind-addr 0.0.0.0:8080 --disable-telemetry --disable-update-check --disable-getting-started-override --disable-workspace-trust


# Image size: 1.9gb
# /opt: 1.5gb
# vscode extensions: 200mb
# debian base: 120mb
