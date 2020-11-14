FROM edgevpnio/evio-base:1.0
WORKDIR /root/
COPY ./edge-vpnio.deb .
RUN apt-get install -y ./edge-vpnio.deb && rm -rf /var/lib/apt/lists/* && apt-get autoclean

CMD ["/sbin/init"]

