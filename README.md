# Setup volumes

In this part, the data is loaded into the db. The data is loaded in a directory mapped as a docker volume. Later the backup is taken of each volume and stored in a central accessible location. 

Download data at https://timescaledata.blob.core.windows.net/datasets/nyc_data.tar.gz and place it in ./nyc.
Extract the tar file in ./nyc

    docker-compose down -v --remove-orphans
    docker-compose up -d tsdb
    sleep 5
    docker-compose exec -T tsdb psql -U postgres < sql/nyc_data.sql
    echo '\COPY rides FROM /nyc_data/nyc_data_rides.csv CSV;' | docker-compose exec -T tsdb psql -U postgres
    docker-compose exec -T tsdb psql -U postgres < sql/nyc_geom.sql
    docker-compose exec -T tsdb psql -U postgres < sql/schema_iot.sql

Create grafana datasource and dashboards

    docker-compose stop
    docker-compose run --rm tsdb-backup
    docker-compose run --rm grafana-backup

## Backup / restore:

    docker-compose run --rm tsdb-backup
    docker-compose run --rm grafana-backup

    docker-compose run --rm tsdb-restore
    docker-compose run --rm grafana-restore

# Run

Download data backup data from https://transfer-vinci-energies.netexplorer.pro/fdl/uGHmJIaNIPsofDCkSeo8I7LhfcDRkj and store it in ./backup.
    
    wget https://transfer-vinci-energies.netexplorer.pro/fdl/b4qZSBXZFz6DivVmk4wm2SHRgW1HEF -O backup/grafana.tar.gz
    wget https://transfer-vinci-energies.netexplorer.pro/fdl/J0ACLfRLqVujNFMoXSq9UB6oEk_hmN -O backup/tsdb.tar.gz

    docker-compose run --rm tsdb-restore
    docker-compose run --rm grafana-restore

    docker-compose up -d tsdb grafana
    docker-compose exec tsdb psql -U postgres

## IoT Sensor data

Follow steps on https://docs.timescale.com/timescaledb/latest/tutorials/simulate-iot-sensor-data/

## New York Cab data
Follow steps in https://docs.timescale.com/timescaledb/latest/tutorials/nyc-taxi-cab/#mission-2-analysis


Without unnecessary geo transformation:



    -- How many taxis pick up rides within 400m of Times Square on New Years Day, grouped by 30 minute buckets.
    -- Number of rides on New Years Day originating within 400m of Times Square, by 30 min buckets
    -- Note: Times Square is at (lat, long) (40.7589,-73.9851)
    SELECT time_bucket('30 minutes', pickup_datetime) AS thirty_min, COUNT(*) AS near_times_sq
    FROM rides
    WHERE ST_Distance(pickup_geom, ST_SetSRID(ST_MakePoint(-73.9851,40.7589),4326)) < 400
    AND pickup_datetime < '2016-01-01 14:00'
    GROUP BY thirty_min ORDER BY thirty_min;



    SELECT time_bucket('5m', rides.pickup_datetime) AS time,
    rides.trip_distance AS value,
    rides.pickup_latitude AS latitude,
    rides.pickup_longitude AS longitude
    FROM rides
    WHERE 
    ST_Distance(pickup_geom,
    ST_SetSRID(ST_MakePoint(-73.9851,40.7589),4326)
    ) < 2000
    GROUP BY time,
    rides.trip_distance,
    rides.pickup_latitude,
    rides.pickup_longitude
    ORDER BY time
    LIMIT 500;


    SELECT time_bucket('5m', rides.pickup_datetime) AS time,
       rides.trip_distance AS value,
       rides.pickup_latitude AS latitude,
       rides.pickup_longitude AS longitude
    FROM rides
    WHERE $__timeFilter(rides.pickup_datetime) AND
    ST_Distance(pickup_geom,
    ST_SetSRID(ST_MakePoint(-73.9851,40.7589),4326)
    ) < 2000
    GROUP BY time,
    rides.trip_distance,
    rides.pickup_latitude,
    rides.pickup_longitude
    ORDER BY time
    LIMIT 500;



