# Steps to Run Portal docker

- Create the docker network to run the dockers

    ```shell
    docker network create evionet
    ```

- Run the below command to start the mongo DB docker.

    ```shell
    docker run -d -p 27017-27019:27017-27019 --network evionet --rm --name mongodb mongo mongod --replSet Evio-rs0
    ```

- Run the below command from the host shell:

    ```shell
    mongo Evio --eval "rs.initiate()"
    ```

- Create a directory on the host to be mounted in the container's filesystem, eg. ~/evio/portal

    ```shell
    mkdir portal && cd portal
    ```

- Copy the configuration file from [.env](https://github.com/EdgeVPNio/portal/blob/master/.env) into the portal directory.

- Replace the value of the key `DB_URI` with the name of the mongo container

    ```shell
    DB_URI=mongodb
    ```

- Run the below command to start the portal container
  The port number can be changed at your convenience.

    ```shell
    docker run -d -p 5000:5000 --name visualizer -v $HOME/evio/portal/.env:/etc/evio/config/.env --rm --privileged --network evionet edgevpnio/evio-portal:0.1
    ```
