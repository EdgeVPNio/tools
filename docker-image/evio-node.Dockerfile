FROM kcratie/evio-base:1.0
WORKDIR /root/
COPY ./edge-vpnio_20.7_amd64.deb .
RUN apt-get install -y ./edge-vpnio_20.7_amd64.deb && rm -rf /var/lib/apt/lists/* && apt-get autoclean

CMD ["/sbin/init"]
