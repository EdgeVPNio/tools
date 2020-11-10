FROM edgevpnio/evio-base:1.0
WORKDIR /root/
COPY ./*.deb .
RUN apt-get install -y ./*.deb && rm -rf /var/lib/apt/lists/* && apt-get autoclean

CMD ["/sbin/init"]

