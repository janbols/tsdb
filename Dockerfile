FROM timescale/timescaledb:2.4.1-pg13

COPY ./db/pgdata /var/lib/postgresql/data/pgdata

ENV PGDATA=/var/lib/postgresql/data/pgdata


