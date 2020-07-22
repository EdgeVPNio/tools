FROM solita/ubuntu-systemd:18.04
WORKDIR /root/
#fix for bad network URL proxy
COPY ./99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy
RUN apt-get update -y && apt-get install -y \
    psmisc \
    iputils-ping \
    nano \
    python3.6 \
    python3.6-dev \
    python3-pip \
    python3-venv \
    iproute2 \
    openvswitch-switch \
    bridge-utils \
    iperf \
    tcpdump

COPY ./setup-prereqs.sh .
RUN chmod +x ./setup-prereqs.sh
RUN ./setup-prereqs.sh
