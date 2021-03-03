FROM ubuntu:20.04
RUN apt update
RUN apt-get install -y git
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install nodejs
RUN git clone https://github.com/EdgeVPNio/portal.git
WORKDIR "/portal"
RUN npm install --legacy-peer-deps
RUN npm run build
EXPOSE 5000
COPY ./run.sh .
CMD ./run.sh