## Setup IoT Sensor data
Follow steps on https://docs.timescale.com/timescaledb/latest/tutorials/simulate-iot-sensor-data/

    docker run -d --name iot \
    -p 5432:5432 \
    -e POSTGRES_PASSWORD=password \
    timescale/timescaledb:2.4.1-pg13

    docker exec -i iot psql -U postgres < schema_iot.sql
    docker exec -ti iot psql -U postgres

## Setup NFL

Follow steps on https://docs.timescale.com/timescaledb/latest/tutorials/nfl-analytics/ingest-and-query/ for getting sample data and unzip the files in the `data` dir.

Create a docker image with prepared database containing the relevant data:

    sudo rm -rf ./db
    sudo rm -f nfl.docker
    docker run -d --name timescaledb \
        -p 5432:5432 \
        -e POSTGRES_PASSWORD=password \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        -v $PWD/db:/var/lib/postgresql/data \
        timescale/timescaledb:2.4.1-pg13
    
    docker exec -i timescaledb psql -U postgres < schema_nfl.sql

    pip install psycopg2-binary
    python3 ingest.py
    docker rm -f timescaledb
    sudo chmod a+r -R  db
    sudo docker build -t summerschool/tsdb/nfl .

    #sudo docker save -o nfl.docker summerschool/tsdb/nfl


## RUN 

    docker run -d --name nfl \
        -p 5432:5432 \
        -e POSTGRES_PASSWORD=password \
        summerschool/tsdb/nfl
    

    docker exec -it nfl psql -U postgres

Following instructions on https://docs.timescale.com/timescaledb/latest/tutorials/nfl-analytics/ingest-and-query/##run-your-first-query
