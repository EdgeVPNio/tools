FROM ubuntu:20.04
RUN apt update
RUN apt-get install -y git
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install nodejs
RUN apt-get install -y wget
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get install -y mongodb-org
RUN apt-get install -y systemd
RUN git clone https://github.com/EdgeVPNio/portal.git
WORKDIR "/portal"
RUN npm install --legacy-peer-deps
RUN cd views && npm run build
EXPOSE 3000
VOLUME ["/data/db"]
COPY ./run.sh .
CMD ./run.sh


