# Steps to Run Portal docker

- Install docker by following the documentation: [docker on ubuntu](https://docs.docker.com/engine/install/ubuntu/)

- Create the docker network to run the dockers

    ```shell
    docker network create evionet
    ```

- Run the below command to start the mongo DB docker.

    ```shell
    docker run -d -p 27017-27019:27017-27019 --network evionet --rm --name mongodb mongo mongod --replSet Evio-rs0
    ```
    or the below command to start the influx db docker.
    ```shell
    docker run --rm -d --network evionet --name influxdb -p 8086:8086 influxdb:1.7
    ```    

- Run the below command from the host shell (skip this step for influxDB):

    ```shell
    mongo Evio --eval "rs.initiate()"
    ```

- Create a directory on the host to be mounted in the container's filesystem, eg. ~/evio/portal

    ```shell
    mkdir portal && cd portal
    ```

- Copy the configuration file from [.env](https://github.com/EdgeVPNio/portal/blob/master/.env) into the portal directory.

- Replace the value of the key `DB_URI` with the name of the mongo/influx container

    ```shell
    DB_URI=mongodb
    ```
    or
    ```shell
    DB_URI=influxdb
    ```

- Run the below command to start the portal container
  The port number can be changed at your convenience.

    ```shell
    docker run -d -p 5000:5000 --name visualizer -v $HOME/evio/portal/.env:/etc/evio/config/.env --rm --privileged --network evionet edgevpnio/evio-portal:0.1
    ```
