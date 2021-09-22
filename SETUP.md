# Setup volumes

In this part, the data is loaded into the db. The data is loaded in a directory mapped as a docker volume. Later the backup is taken of each volume and stored in a central accessible location. 

Download data at https://timescaledata.blob.core.windows.net/datasets/nyc_data.tar.gz and place it in ./nyc.
Extract the tar file in ./nyc


Download data at https://s3.amazonaws.com/assets.timescale.com/docs/downloads/weather_data.zip and place it in ./weather.
Extract the zip file in ./weather

    docker-compose down -v --remove-orphans
    sudo chown -R  1001:1001 ./postgresconf
    docker-compose up -d tsdb
    sleep 5
    docker-compose exec -T tsdb psql -U postgres < sql/nyc_data.sql
    echo '\COPY rides FROM /nyc_data/nyc_data_rides.csv CSV;' | docker-compose exec -T tsdb psql -U postgres
    docker-compose exec -T tsdb psql -U postgres < sql/nyc_geom.sql
    docker-compose exec -T tsdb psql -U postgres < sql/schema_iot.sql
    docker-compose exec -T tsdb psql -U postgres < sql/weather.sql
    echo '\COPY weather.weather_metrics FROM /weather/weather_data.csv CSV HEADER;' | docker-compose exec -T tsdb psql -U postgres





Create grafana datasource and dashboards

    docker-compose stop
    docker-compose run --rm tsdb-backup
    docker-compose run --rm grafana-backup

## Backup / restore:

    docker-compose run --rm tsdb-backup
    docker-compose run --rm grafana-backup

    docker-compose run --rm tsdb-restore
    docker-compose run --rm grafana-restore


