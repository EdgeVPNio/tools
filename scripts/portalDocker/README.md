# Steps to Run Portal docker

- Run the below command to start the mongo DB docker.

    ```
    docker run -d -p 27017-27019:27017-27019 --network dkrnet --name mongodb mongo
    ```

- Create a directory inside the evio directory situated in the HOME directory.

    ```
    mkdir portal && cd portal
    ```

- Copy the .env file from [.env](https://github.com/EdgeVPNio/portal/blob/master/.env) into the portal directory.

- Replace the `DB_URI` with the name of the MongoDB container you gave in the first command.

    ```
    DB_URI=<NAME OF Mongo Container>
    ```

- Run the below command to start the portal container

    ```
    docker run -d -p 5000:5000 --name Evioportal -v $HOME/evio/portal/.env:/etc/evio/config/.env --privileged --network dkrnet edgevpnio/evio-portal:0.1
    ```
