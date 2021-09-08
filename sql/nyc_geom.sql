CREATE EXTENSION postgis;


-- Create geometry columns for each of our (lat,long) points
ALTER TABLE rides ADD COLUMN pickup_geom geometry(POINT,4326);
ALTER TABLE rides ADD COLUMN dropoff_geom geometry(POINT,4326);

-- Generate the geometry points and write to table
UPDATE rides SET pickup_geom = ST_SetSRID(ST_MakePoint(pickup_longitude,pickup_latitude),4326),
                 dropoff_geom = ST_SetSRID(ST_MakePoint(dropoff_longitude,dropoff_latitude),4326);
