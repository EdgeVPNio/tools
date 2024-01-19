FROM ubuntu:jammy AS base
RUN echo 'root:root' | chpasswd
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d
RUN apt-get update && \
    apt-get install -y systemd systemd-sysv dbus dbus-user-session

FROM base AS evio-base
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get update || true 
RUN apt-get install -y \
        openvswitch-switch \
        libffi-dev \
        software-properties-common \
        iproute2 \
        bridge-utils && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update
RUN apt-get install -y \
    python3.9 \
    python3.9-dev \
    python3.9-venv \
    python3-pip \
    python3-wheel

WORKDIR /opt/evio/
ENV VIRTUAL_ENV=/opt/evio/venv
RUN python3.9 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install --upgrade pip && \
    pip3 --cache-dir /var/cache/evio/ \
        install wheel && \
    pip3 --cache-dir /var/cache/evio/ \
         install eventlet==0.30.2 \
         slixmpp requests simplejson \
         pyroute2 keyring ryu
#RUN systemctl mask getty@tty1.service

FROM evio-base
WORKDIR /var/cache/evio 
ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM
COPY ./evio_$TARGETARCH.deb .
WORKDIR /root
RUN apt-get install -y /var/cache/evio/evio_$TARGETARCH.deb && \
    rm -rf /var/lib/apt/lists/* \
        /var/cache/evio/ && \
    apt-get autoclean
CMD ["/sbin/init"]

ARG DATE
ARG VERSION
ENV CREATED=$DATE
ENV VERSION=$VERSION

LABEL org.opencontainers.image.created=$DATE \
  org.opencontainers.image.authors="ken, renato" \
  org.opencontainers.image.url="https://edgevpn.io" \
  org.opencontainers.image.source="https://github.com/EdgeVPNio/evio" \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.title="Virtualized overlay networking for the fog"
