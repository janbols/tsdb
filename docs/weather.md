# Getting started with weather data

Copied from <https://docs.timescale.com/timescaledb/latest/getting-started/>

# ~~Create a hypertable~~ (already done)
When you have launched your first TimescaleDB instance and accessed your database, you can create your first hypertable. Hypertables are the heart of TimescaleDB and are what allows TimescaleDB to work so effectively with time-series data.

## ~~Chunks and hypertables~~ (already done)
Chunks and hypertables make storing and querying times-series data blazing fast
at peta-byte scale. TimescaleDB automatically partitions time-series data into
chunks, or sub-tables, based on time and space. For example, chunks can be based
on hash key, device ID, location or some other distinct key. You can configure
chunk size so that recent chunks fit memory for faster queries.

A hypertable is an abstraction layer over chunks that hold time-series data.
Hypertables allow you to query and access data from all the chunks as if they
were in a single table. This is because commands issued to the hypertable are
applied to all of the chunks that belong to that hypertable.

Hypertables and chunks enable superior performance for shallow and wide queries,
like those used in real-time monitoring. They are also good for deep and narrow
queries, like those used in time-series analysis.

<img class="main-content__illustration" src="https://assets.iobeam.com/images/docs/illustration-hypertable-chunk.svg" alt="hypertable and chunks"/>

You can interact with chunks individually if you need to, but chunks are created
automatically based on the `chunk_time` and `chunk_size` parameters you specify.

**Create your first hypertable**

```sql
----------------------------------------
-- Hypertable to store weather metrics
----------------------------------------
-- Step 1: Define regular table
CREATE TABLE IF NOT EXISTS weather_metrics (

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
SELECT create_hypertable('weather_metrics','time');
```

Creating a hypertable is a two step process. Start by using a `CREATE TABLE`
statement to create a regular relational table. Then you can use a `SELECT`
statement with the `create_hypertable` function to convert the table into a
hypertable. The `SELECT` statement requires the name of the table to convert,
and the name of the time column in that table.

## ~~How hypertables help with times-series data~~ (already done)
**Hypertables help speed up ingest rates:** Because data is only inserted into
the current chunk, data in the other chunks remains untouched. If you use a
single table, every time you ingest data into the table it becomes bigger and
more bloated.

**Hypertables help speed up queries:** Because only specific chunks are queried
thanks to the automatic indexing by time or space.

The value of hypertables is in how data is partitioned on disk. The index value
is automatically augmented by the time dependency of the data to allow more
focused use of memory and query planning resources. In PostgreSQL (and other
relational database management systems), you can build indexes on one or more
values, but the data must still be retrieved. Retrieval is in most cases, from
portions of the physical layer (memory or disk), which doesn't always result in
effective use of memory and disk resources. By automatically partitioning on
time, transparently, hypertables improve resource use and queries and
data-stores become more efficient.

Next, ingest some sample data into TimescaleDB.

# ~~4. Add time-series data~~ (already done)

To showcase TimescaleDB and get you familiar with its features, we’ll need some
sample data to play around with. We’ll use the real-world scenario of climate
change. Data about the climate in a certain region is time-series data, as it
describes how the climate in that area changes over time.

## ~~About the dataset~~ (already done)

Our dataset comes from [OpenWeatherMap](https://openweathermap.org) and contains
measurements for 10 cities in which Timescalers reside: New York City, San Francisco,
Princeton, Austin, Stockholm, Lisbon, Pietermaritzburg, Nairobi, Toronto and Vienna.

The dataset contains weather metrics for each city from 1 January 1979 to 27 April 2021.

For each city, we record the following metrics:
```bash
* time: timestamp of data calculation
* timezone: Shift in seconds from UTC
* city_name: City name
* temp_c: Temperature in degrees celsius
* feels_like_c:  This temperature parameter accounts for the human perception of weather
* temp_min_c: Minimum temperature
* temp_max_c Maximum temperature
* pressure_hpa: Atmospheric pressure (on the sea level) in hPa
* humidity_percent:  humidity as a percentage of
* wind_speed_ms: Wind speed in meters per second
* wind_deg: Wind direction, degrees (meteorological)
* rain_1h: Rain volume for the last hour, mm
* rain_3h: Rain volume for the last 3 hours, mm
* snow_1h: Snow volume for the last hour, in mm
* snow_3h: Snow volume for the last 3 hours, in mm
* clouds_percent: Cloudiness as a percentage of
* weather_id: Weather condition id
```

## ~~Accessing the dataset~~ (already done)

We provide a csv file with commands for inserting the data into your TimescaleDB instance.

Download the CSV file (in ZIP format) below and insert it into your database from psql.

Download CSV: <tag type="download">[weather_data.zip](https://s3.amazonaws.com/assets.timescale.com/docs/downloads/weather_data.zip)</tag>

After unzipping the file, use the following command (which assumes `weather_data.csv` is located in your current directory):

```sql
-- copy data from weather_data.csv into weather_metrics
\copy weather_metrics (time, timezone_shift, city_name, temp_c, feels_like_c, temp_min_c, temp_max_c, pressure_hpa, humidity_percent, wind_speed_ms, wind_deg, rain_1h_mm, rain_3h_mm, snow_1h_mm, snow_3h_mm, clouds_percent, weather_type_id) from './weather_data.csv' CSV HEADER;
```
Now that you’re up and running with historical data inside TimescaleDB and a
method to ingest the latest data into your database, let’s start querying the data.

# 5. Query your data

With TimescaleDB, there's no need to learn a custom query language. **TimescaleDB
supports full SQL**. This means you can put your SQL knowledge to good use and
use the rich ecosystem of PostgreSQL tools you know and live.

For example, here's how to find the average temperature for each city in the past 2 years:

```sql
--------------------------------
-- Average temperature per city
-- in past 2 years
--------------------------------
SELECT city_name, avg(temp_c)
FROM weather_metrics
WHERE time > now() - INTERVAL '2 years'
GROUP BY city_name;
```

And here's how to find the total snowfall for each city in the past 5 years:

```sql
--------------------------------
-- Total snowfall per city
-- in past 5 years
--------------------------------
SELECT city_name, sum(snow_1h_mm)
FROM weather_metrics
WHERE time > now() - INTERVAL '5 years'
GROUP BY city_name;
```


<highlight type="tip">
Fun fact: TimescaleDB adds important enhancements to the PostgreSQL query planner
that improve query reusability for INTERVAL predicates, something PostgreSQL does
not have.
</highlight>

## Advanced SQL functions for time-series data

Timescale has many custom-built SQL functions to help you perform time-series
analysis in fewer lines of code.

Examples of these functions include:

* [`time_bucket()`] - used for analyzing data over arbitrary time intervals
* [`first()`] - used for finding the earliest value based on a time within an aggregate group
* [`last()`] - used for finding the latest value based on time within an aggregate group
* [`time_bucket_gapfill()`] - used to analyze data over arbitrary time intervals and fill any gaps in the data
* [`locf()`] - used to fill gaps in data by carrying the last observed value forward
* [`interpolate()`] - used fill gaps by linearly interpolating the missing values between known data points

Let's take a closer look at time_bucket.

### time_bucket()

Here's an example of how to use [`time_bucket()`] to find the average temperature per 15 day period, for each city, in the past 6 months:

```sql
-----------------------------------
-- time_bucket
-- Average temp per 15 day period
-- for past 6 months, per city
-----------------------------------
SELECT time_bucket('15 days', time) as "bucket"
   ,city_name, avg(temp_c)
   FROM weather_metrics
   WHERE time > now() - (6* INTERVAL '1 month')
   GROUP BY bucket, city_name
   ORDER BY bucket DESC;
```

With time_bucket, you can monitor, analyze and visualize time-series data in the time intervals that matter most for your use-case (e.g 10 seconds, 15 minutes, 6 hours - whatever your time period of interest happens to be). This is because time_bucket enables you to segment data into arbitrary time intervals. Such intervals are often required when analyzing time-series data, but can sometimes be unwieldy depending on the constraints of the database, query language or all in one tool that you use.

For readers familiar with PostgreSQL, you can think of time_bucket as a more powerful version of the PostgreSQL date_trunc function. Time_bucket allows for arbitrary time intervals, rather than the standard day, minute, hour provided by date_trunc.

Time_bucket is just one of many TimescaleDB custom-built SQL functions to help you perform more insightful time-series analysis in fewer lines of code. Another powerful function for time-series analysis is time_bucket_gapfill.

### time_bucket_gapfill()

Another common problem in time-series analysis is dealing with imperfect datasets.
Some time-series analyses or visualizations want to display records for each
selected time period, even if no data was recorded during that period. This is
commonly termed "gap filling", and may involve performing such operations as
recording a "0" for any missing data, interpolating missing values, or carrying
the last observed value forward until new data is recorded.

Timescale provides [`time_bucket_gapfill()`],
[`locf()`], and [`interpolate()`] to help perform analysis on data with gaps,

In our sample dataset, we have days where there is no rain or snow for a particular
city. However, we might still want to perform an analysis or graph a trend line
about rain or snow for a particular time period.

For example, here's a query which calculates the total snowfall for each city in
30 day time periods for the past year:

```sql
-- non gapfill query
SELECT time_bucket('30 days', time) as bucket,
   city_name, sum(snow_1h_mm) as sum
   FROM weather_metrics
   WHERE time > now() - INTERVAL '1 year' AND time < now()
   GROUP BY bucket, city_name
   ORDER BY bucket DESC;
```

Notice that the results only include time_periods for when cities have snowfall,
rather than the specific time period of our analysis, which is one year.

To generate data for all the time buckets in our analysis period, we can use
time_bucket_gapfill instead:

```sql
-----------------------------------------
-- time_bucket_gapfill
-- total snow fall per city
-- in 30 day buckets for past 1 year
-----------------------------------------
SELECT time_bucket_gapfill('30 days', time) as bucket,
   city_name, sum(snow_1h_mm) as sum
   FROM weather_metrics
   WHERE time > now() - INTERVAL '1 year' AND time < now()
   GROUP BY bucket, city_name
   ORDER BY bucket DESC;
```

TimescaleDB SQL functions like time_bucket and time_bucket_gapfill are helpful
for historical analysis of your data and creating visuals with specific time-periods.

Now that you're equipped with the basics of time_bucket, let's learn about Continuous
Aggregates in the next section.


# 6. Create a continuous aggregate

## What are continuous aggregates?

**Aggregates** are summaries of raw data for a period of time. Some examples of
aggregates are the average temperature per day, the maximum CPU utilization per
5 minutes, and the number of visitors on a website per day.

Calculating aggregates on time-series data can be computationally intensive given
the large amounts of data which need to be processed in order to calculate and
recalculate aggregates over a time period. Moreover, calculating aggregates
while simultaneously ingesting data can cause a slowdown in ingest rate due to
the computational resources being split between the two resource intensive
processes. Continuous aggregates solve both these problems.

**Continuous aggregates** are automatically refreshed materialized views – so
they massively speed up workloads that need to process large amounts of data.
Unlike in other databases, your views are automatically refreshed in the background
as new data is added, or as old data is modified according to a schedule.

* Continuous aggregates automatically and in the background pre-calculate and
  maintain the results from a specified query, and allow you to retrieve the results
  as you would any other data.
* The views are automatically refreshed in the background as new data is added,
  or as old data is modified according to a schedule.

For Postgres users who may be familiar with views and materialized views, here's
how continuous aggregates differ:

* Unlike a PostgreSQL view a continuous aggregate does not perform the computation when queried
* Unlike a materialized view, it does not need to be refreshed manually, as it
  can be refreshed according to a schedule.

Continuous aggregates speed up dashboards and visualizations, summarizing data
sampled at high frequency, and querying downsampled data over long time periods.

## Creating continuous aggregates

Now that you're familiar with what Continuous Aggregates are, let's create our
first continuous aggregate. Creating a continuous aggregate is a two step process:
first we define our view and second, we create a policies which will refresh the
continuous aggregate according to a schedule.

We'll use the example of creating a daily aggregation of all weather metrics.

### Step 1: Define view

Here's the SQL query which defines the query of which we want to maintain the
results. In this case, we calculate the daily average for all weather metrics,
as well as the maximum and minimum for temperature.

```sql
-- Continuous aggs
-- define view
CREATE MATERIALIZED VIEW weather_metrics_daily
WITH (timescaledb.continuous)
AS
SELECT
   time_bucket('1 day', time) as bucket,
   city_name,
   avg(temp_c) as avg_temp,
   avg(feels_like_c) as feels_like_temp,
   max(temp_c) as max_temp,
   min(temp_c) as min_temp,
   avg(pressure_hpa) as pressure,
   avg(humidity_percent) as humidity_percent,
   avg(rain_3h_mm) as rain_3h,
   avg(snow_3h_mm) as snow_3h,
   avg(wind_speed_ms) as wind_speed,
   avg(clouds_percent) as clouds
FROM
 weather_metrics
GROUP BY bucket, city_name
WITH NO DATA;
```

Notice how we use our friend `time_bucket` from the previous section to specify that we want to bucket the data by 1 day time periods.

You can create multiple continuous aggregates on the same hypertable, but for simplicity sake we'll just create one for now.

Here's some ideas for other aggregates to create:

* 6 month aggregates for all metrics for a specific city.
* 30 day aggregates for temperature and rainfall for all cities.
* 5 year aggregates for all metrics for certain cities.

<highlight type="tip">
If you ever need to inspect details about a continuous aggregate, such as its configuration or the query used to define it, you can use the following informational view:
</highlight>

```sql
-- See info about continuous aggregates
SELECT * FROM timescaledb_information.continuous_aggregates;
```

### Step 2: Populate the continuous aggregate

Right now we've created the continuous aggregate but it has not materialized any
data. There are two ways to populate a continuous aggregate: via manual refresh
or an automation policy. These methods enable you to refresh materialized data
in your continuous aggregates when its most convenient for you (e.g during low
query load times on your database).

Let's take a look at how to do each one.

#### Manual refresh

You can manually refresh a continuous aggregate by means of a "one-shot refresh".
This is useful for refreshing data for only a specific time-period in the past
or if you want to materialize a lot of data at once on a once-off basis.

The example below refreshes the continuous aggregate `weather_metrics_daily` for
the time period starting 1 January 2010 and ending 1 January 2021:

```sql
-- manual refresh
-- refresh data between 1 Jan 2010 and 2021
CALL refresh_continuous_aggregate('weather_metrics_daily','2010-01-01', '2021-01-01');
```

Querying our continuous aggregate for data older than 1 January 2009 shows that
it is indeed populated with data from the above time frame, as the first row
returned is for 1 January 2010:

```sql
-- Show that manual refresh worked
SELECT * from weather_metrics_daily
WHERE bucket > '2009-01-01'
ORDER BY bucket ASC;
```

#### Automation policies

An **automation policy** can also be used to refresh continuous aggregates according to a schedule.

While many databases have ad-hoc capabilities for managing large amounts of
time-series data, adapting these features to the rhythm of your data lifecycle
often requires custom code and regular development time.

Enter TimescaleDB's built-in background jobs capability, often referred to as
Automation Policies.

Using automation policies for updating continuous aggregates is the first of many
automation policies you'll encounter in TimescaleDB. TimescaleDB also has policies
to automate compression and data retention. You can also create custom policies and
run them according to a schedule with the User Defined Actions feature. Using this
automation feature allows you to "set it and forget it" on administration tasks
so that you can spend time on feature development.

You'll see policies for compression and data retention later in this **Getting started** section.

Let's create a policy which will auto-update the continuous aggregate every two weeks:

```sql
-- create policy
-- refresh the last 6 months of data every 2 weeks
SELECT add_continuous_aggregate_policy('weather_metrics_daily',
  start_offset => INTERVAL '6 months',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '14 days');
```

The policy above will run every 14 days (`schedule_interval`). When it runs, it
will materialize data from between 6 months (`start_offset`) and 1 hour (`end_offset`)
of the time it executes, according to the query which defined the continuous
aggregate `weather_metrics_daily`.

Automation policies are useful for continuous aggregates which need to return
data from recent time frames, as they help them stay up to date.

## Querying continuous aggregates

<highlight type="tip">
Continuous Aggregates are actually a special kind of hypertable, so you can
query it, view and modify its chunks just like you would a regular hypertable.
You can also add data retention policies and drop chunks on continuous aggregate
hypertables. The only restrictions at this time is that you cannot apply
compression or continuous aggregation to these hypertables.
</highlight>


When you query a continuous aggregate, the system reads and processes the much
smaller materialized table, which has been refreshed at scheduled intervals. This
makes querying continuous aggregates useful for speeding up dashboards, summarizing
data sampled at high frequency, and querying downsampled data over long time periods.

Moreover, querying continuous aggregates does not slow down INSERT operations,
since data is inserted into a different hypertable than the one underlying the
continuous aggregate.

Let's examine an example of a query which would perform better on our continuous
aggregate (`weather_metrics_daily`) than on our hypertable (`weather_metrics`).
Here's a query which looks at how temperatures in New York have changed over the
past 6 years. It returns the returns the time as well as the daily maximum, minimum
and average temperatures for New York City between 2015 and 2021:

```sql
-- Continuous Aggregate query example
-- Temperature in New York 2015-2021
SELECT bucket, max_temp, avg_temp, min_temp
FROM weather_metrics_daily
WHERE bucket >= '2015-01-01' AND bucket < '2021-01-01'
AND city_name LIKE 'New York'
ORDER BY bucket ASC;
```

Such a query executes quickly as the data for the time period in question is
already populated in the continuous aggregate and aggregated by day. Queries like
this are used in historical analysis, often to plot graphs about how temperature
changes over time.

### Real-time aggregation

By default, continuous aggregates support real-time aggregation, which combines
aggregated data and raw data at query time for the most up to date results. (You
can turn this off if desired, but the majority of developers want this behaviour
by default).

**Without real-time aggregation turned off,** continuous aggregates only return r
esults for data in the time period they have materialized (refreshed). If you query
continuous aggregates for data newer than the last materialized time, it will not
return it or return stale results.

**With real-time aggregation turned on, **you always receive up-to-date results,
as querying a continuous aggregate returns data that is already materialized
combined with the newest raw data from the hypertable available at query time.

Real-time aggregation gives you the best of both worlds: the performance of continuous
aggregates and the most up to date data for real time queries, without the
performance degradation of querying and aggregating all raw data from scratch.

For example, consider the results of this query, which selects daily aggregates
of all weather metrics for the past two years:

```sql
-- Real-time aggregation
SELECT * from weather_metrics_daily
  WHERE bucket > now() - 2 * INTERVAL '1 year'
  ORDER BY bucket DESC;
```

The first row returned has a time value newer than 1 January 2021, which is the
end date for which we materialized data in our continuous aggregate (done via
manual refresh earlier in this tutorial). Despite not materializing the latest
data via manual refresh or our policy (since the policy created above hasn't yet
run), we still get the latest data thanks to real-time aggregation.

This makes real-time aggregation an ideal fit for many near real-time, monitoring
and analysis use-cases, especially for dashboarding or reporting that requires
the most up to date numbers all the time. It is for this reason that we recommend
keeping the setting on.

# 7. Compression policies

TimescaleDB comes with native compression capabilities which enable you to analyze and query massive amounts of historical time-series data inside a database, while also saving on storage costs.

TimescaleDB uses best-in-class compression algorithms along with a novel method to create hybrid row/columnar storage. This gives up to 96% lossless compression rates and speeds up common queries on older data. Compressing data increases the amount of time that your data is "useful" (i.e in a database and not in a low-performance object store), without the corresponding increase in storage usage and bill.


<highlight type="tip">
All postgresql data types can be used in compression.

</highlight>

At a high level, TimescaleDB's built-in job scheduler framework will asynchronously convert recent data from an uncompressed row-based form to a compressed columnar form across chunks of TimescaleDB hypertables.

Let's enable compression on our hypertable and then look at two ways of compressing data: with an automatic policy or manually.

## Enable TimescaleDB compression on the hypertable

Just like with Continuous Aggregates, there are two ways to compress data in TimescaleDB: manually, via a one-time command, or using a compression policy to automatically compress data according to a schedule.

The easiest method to compress data is by using a compression policy. Let's create a policy to compress all data older than 10 years.

```sql
-- Enable compression
ALTER TABLE weather_metrics SET (
 timescaledb.compress,
 timescaledb.compress_segmentby = 'city_name'
);
```

This enables compression on the hypertable `weather_metrics`.

The `segmentby` option determines the main key by which compressed data is accessed. In particular, queries that reference the `segmentby` columns in the WHERE clause are very efficient. Thus, it is important to pick the correct set of `segmentby` columns. In this case, we pick `city_name` for the `segmentby` option, since it is common to query older data for just a single city over a long period of time.

<highlight type="tip">
> To learn more about the `segmentby` and `orderby` options for compression in TimescaleDB and how to pick the right columns, see this detailed explanation in the [TimescaleDB compression docs](https://docs.timescale.com/latest/using-timescaledb/compression#react-docs).
</highlight>

We can also view the compression settings for our hypertables by using the `compression_settings` informational view, which returns information about each compression option and its `orderby` and `segmentby` attributes:

```sql
-- See info about compression
SELECT * FROM timescaledb_information.compression_settings;
```

Now that compression is enabled, we need to schedule a policy to automatically compress data according to the settings defined above. We will set a policy to compress data older than 10 years by using the following query:

```sql
-- Add compression policy
SELECT add_compression_policy('weather_metrics', INTERVAL '10 years');
```

Just like for automated policies for continuous aggregates, we can view information and statistics about our compression background job in the following two information views:

```sql
-- Informational view for policy details
SELECT * FROM timescaledb_information.jobs;

-- Informational view for stats from run jobs
SELECT * FROM timescaledb_information.job_stats;
```

**Manual Compression**

While we recommend using compression policies to automated compression data, there might be situations where you need to manually compress chunks. Here's a query which manually compresses chunks that entirely consist of data older than 10 years:

```sql
---------------------------------------------------
-- Manual compression
---------------------------------------------------
SELECT compress_chunk(i)
FROM show_chunks('weather_metrics', older_than => INTERVAL ' 10 years') i;
```
We can see the size of the compressed chunks before and after applying compression by using the following query:

```sql
-- See effect of compression
SELECT pg_size_pretty(before_compression_total_bytes) as "before compression",
  pg_size_pretty(after_compression_total_bytes) as "after compression"
  FROM hypertable_compression_stats('weather_metrics');
```

## Benefits of compression

**Disk space savings**

A straightforward benefit of compressing data in TimescaleDB is that you enjoy disk space savings, enabling you to store more data in a fixed amount of disk space than you otherwise would in other databases (e.g [TimescaleDB uses 10% of the disk space to store the same number of time-series metrics as MongoDB](https://blog.timescale.com/blog/how-to-store-time-series-data-mongodb-vs-timescaledb-postgresql-a73939734016/)).

This is especially beneficial when backups and high-availability replicas are taken into account, as you'd save disk space and storage costs on all databases.

**Better query performance**

In addition to saving storage space and costs, compressing data might increase query performance on certain kinds of queries. Compressed data tends to be older data and older data tends to have different query patterns than recent data.

**Newer data tends to be queried in a shallow and wide fashion**. In this case, shallow refers to the length of time and wide refers to the range of columns queried. These are often debugging or "whole system" queries. For example, "Show me all the metrics for all cities in the last 2 days." In this case the uncompressed, row based format that is native to PostgreSQL will give us the best query performance.

**Older data tends to be queried in a deep and narrow fashion.** In this case, deep refers to the length of time and narrow refers to the range of columns queried. As data begins to age, queries tend to become more analytical in nature and involve fewer columns. For example, "Show me the average annual temperature for city A in the past 20 years". This type of queries greatly benefit from the compressed, columnar format.

TimescaleDB's compression design allows you to get the best of both worlds: recent data is ingested in an uncompressed, row format for efficient shallow and wide queries, and then automatically converted to a compressed, columnar format after it ages and is most often queried using deep and narrow queries.

Here's an example of a deep and narrow query on our compressed data. It calculates the average temperature for New York City for all years in the dataset before 2010. Data for these years will be compressed, since we compressed all data older than 10 years with either our policy or the manual compression method above.

```sql
-- Deep and narrow query on compressed data
SELECT avg(temp_c) FROM weather_metrics
WHERE city_name LIKE 'New York'
AND time < '2010-01-01';
```

# 8. Create a data retention policy

An intrinsic part of working with time-series data is that the relevance of
highly granular data diminishes over time. New data is accumulated and old data
is rarely, if ever, updated. It is therefore often desirable to delete old raw
data to save disk space.

<highlight type="tip">
In practice old data is often downsampled first such that a summary of
it is retained (e.g in a continuous aggregate), while the raw data points are
then discarded, via data retention policies.
</highlight>

Just like for continuous aggregates and compression, TimescaleDB provides an
automated policy to drop data according to a schedule and defined rules. Automated
data retention policies (along with compression and continuous aggregates) give
you more control over how much the amount of data you retain at specific a
granularity and for specific time periods. These policies are "set it and forget it"
in nature, meaning less hassle for maintenance and upkeep.

For example, here is a data retention policy which drops chunks consisting of
data older than 25 years from the hypertable `weather_metrics`:

```sql
-- Data retention policy
-- Drop data older than 25 years
SELECT add_retention_policy('weather_metrics', INTERVAL '25 years');
```


And just like with continuous aggregates and compression policies, we can see
see information about retention policies and statistics about their jobs from the
following informational views:

```sql
-- Informational view for policy details
SELECT * FROM timescaledb_information.jobs;
-- Informational view for stats from run jobs
SELECT * FROM timescaledb_information.job_stats;
```


## Manual data retention

Dropping chunks is also useful when done on a one-off basis. One such case is
deleting large swaths of data from tables -- this can be costly and slow if done
row-by-row using the standard DELETE command. Instead, TimescaleDB provides a
function `drop_chunks` that quickly drop data at the granularity of chunks without
incurring the same overhead.

```sql
-- Manual data retention
SELECT drop_chunks('weather_metrics', INTERVAL '25 years');
```


This will drop all chunks from the hypertable conditions *that only include data
older than the specified duration* of 25 years, and will *not* delete any individual rows of data in chunks.

## Downsampling

We can combine continuous aggregation and data retention policies to implement
downsampling on our data. We can downsample high fidelity raw data into summaries
via continuous aggregation and then discard the underlying raw observations from
our hypertable, while retaining our aggregated version of the data.

We can also take this a step further, by applying data retention policies (or
using drop_chunks) on continuous aggregates themselves, since they are a special
kind of hypertable. The only restrictions at this time is that you cannot apply
compression or continuous aggregation to these hypertables.
