FROM edgevpnio/evio-base:1.2
WORKDIR /root/
COPY ./evio.deb .
RUN apt-get install -y ./evio.deb && rm -rf /var/lib/apt/lists/* && apt-get autoclean

CMD ["/sbin/init"]

