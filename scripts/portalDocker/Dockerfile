FROM ubuntu:20.04
RUN apt update
RUN apt-get install -y git
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install nodejs
RUN apt-get install -y wget
RUN apt-get update
RUN git clone https://github.com/EdgeVPNio/portal.git
WORKDIR "/portal"
RUN npm install --legacy-peer-deps
RUN cd views && npm run build
EXPOSE 5000
CMD "node server/Server.js"
