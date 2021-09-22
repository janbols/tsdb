CREATE SCHEMA IF NOT EXISTS weather AUTHORIZATION postgres ;

----------------------------------------
-- Hypertable to store weather metrics
----------------------------------------
-- Step 1: Define regular table
CREATE TABLE IF NOT EXISTS weather.weather_metrics (

                                               time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
                                               timezone_shift int NULL,
                                               city_name text NULL,
                                               temp_c double PRECISION NULL,
                                               feels_like_c double PRECISION NULL,
                                               temp_min_c double PRECISION NULL,
                                               temp_max_c double PRECISION NULL,
                                               pressure_hpa double PRECISION NULL,
                                               humidity_percent double PRECISION NULL,
                                               wind_speed_ms double PRECISION NULL,
                                               wind_deg int NULL,
                                               rain_1h_mm double PRECISION NULL,
                                               rain_3h_mm double PRECISION NULL,
                                               snow_1h_mm double PRECISION NULL,
                                               snow_3h_mm double PRECISION NULL,
                                               clouds_percent int NULL,
                                               weather_type_id int NULL
);

-- Step 2: Turn into hypertable
SELECT create_hypertable('weather.weather_metrics','time');




ALTER DATABASE postgres SET search_path TO public,iot,weather;
