## Setup

    sudo rm -rf ./db
    sudo rm -f nfl.docker

    docker run -d --name timescaledb \
        -p 5432:5432 \
        -e POSTGRES_PASSWORD=password \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        -v $PWD/db:/var/lib/postgresql/data \
        timescale/timescaledb:2.4.1-pg13
    
    docker exec -i timescaledb psql -U postgres < schema.sql
    
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
