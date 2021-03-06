# Slides
You can view the presentation by downloading the [slides directory](./slides) and opening the index.html in your browser.

# Getting started

Get the tsdb.tar.gz from a USB stick or by running the setup as described in [the setup page](./SETUP.md).

Restore the volumes for tsdb and grafana by running the commands below:

    # sudo chown -R  1001:1001 ./postgresconf

    docker-compose run --rm tsdb-restore
    docker-compose run --rm grafana-restore

    docker-compose up -d tsdb grafana

## Verify installation
To verify a correct installation run the following:
```bash
docker-compose exec tsdb psql -U postgres
```
You should see the following connection message:

```bash
psql (13.4)
Type "help" for help.

postgres=# 
```
To verify that TimescaleDB is installed, run the `\dx` command
to list all installed extensions to your PostgreSQL database.
You should see something similar to the following output:

```sql
                                       List of installed extensions
    Name     | Version |   Schema   |                             Description                             
-------------+---------+------------+---------------------------------------------------------------------
 plpgsql     | 1.0     | pg_catalog | PL/pgSQL procedural language
 postgis     | 3.0.3   | public     | PostGIS geometry, geography, and raster spatial types and functions
 timescaledb | 2.4.1   | public     | Enables scalable inserts and complex queries for time-series data
(3 rows)
```
To verify the tables created in the databaserun the `\dt` command
in the `psql` command line. You should see the following:

```sql
           List of relations
 Schema |     Name      | Type  |  Owner
--------+---------------+-------+----------
 public | payment_types | table | postgres
 public | rates         | table | postgres
 public | rides         | table | postgres
(3 rows)
```
## Weather
Follow steps in [./docs/weather.md](./docs/weather.md)
## IoT Sensor data
Follow steps on [./docs/iot.md](./docs/iot.md)
## New York Cab data
Follow steps in [./docs/nyc.md](./docs/nyc.md)
## Grafana
Follow steps in [./docs/grafana.md](./docs/grafana.md)
