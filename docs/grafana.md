# Creating a Grafana dashboard and panel

Grafana is organized into ‘Dashboards' and ‘Panels'. A dashboard represents a view
onto the performance of a system, and each dashboard consists of one or more panels,
which represents information about a specific metric related to that system.

In this tutorial, you'll build a simple dashboard, connect it to TimescaleDB, and visualize
data.

### ~~Prerequisites~~ (already done)

To complete this tutorial, you will need a cursory knowledge of the Structured Query
Language (SQL). The tutorial will walk you through each SQL command, but it will be
helpful if you've seen SQL before.

* To start, [install TimescaleDB][install-timescale].
* Next [setup Grafana][install-grafana].

Once your installation of TimescaleDB and Grafana are complete, ingest the data found
in the [NYC Taxi Cab][nyc-taxi] tutorial and configure Grafana to connect
to that database. Be sure to follow the full tutorial if you're interested in background
on how to use TimescaleDB.

### ~~Build a new dashboard~~ (already done)

We will start by creating a new dashboard. In the far left of the Grafana user
interface, you'll see a '+' icon. If you hover over it, you'll see a 'Create' menu,
within which is a 'Dashboard' option. Select that 'Dashboard' option.

After creating a new dashboard, you'll see a 'New Panel' screen, with options
for 'Add Query' and 'Choose Visualization'. In the future, if you already have a
dashboard with panels, you can click on the '+' icon at the **top** of the Grafana user
interface, which will enable you to add a panel to an existing dashboard.

To proceed with our tutorial, let's add a new visualization by clicking on the 'Choose
Visualization' option.

At this point, you'll have several options for different Grafana visualizations. We will
choose the first option, the 'Graph' visualization.

<img class="main-content__illustration" src="https://assets.iobeam.com/images/docs/screenshots-for-grafana-tutorial/grafana_visualizations.png" alt="Grafana visualizations to choose from"/>

There are multiple ways to configure our panel, but we will accept all the defaults
and create a simple 'Lines' graph.

In the far left section of the Grafana user interface, select the 'Queries' tab.

<img class="main-content__illustration" src="https://assets.iobeam.com/images/docs/screenshots-for-grafana-tutorial/create_grafana_query.png" alt="How to create a new Grafana query"/>

Instead of using the Grafana query builder, we will edit our query directly. In the
view, click on the 'Edit SQL' button at the bottom.

<img class="main-content__illustration" src="https://assets.iobeam.com/images/docs/screenshots-for-grafana-tutorial/edit_sql_in_grafana.png" alt="Edit custom SQL queries in Grafana"/>

Before we can begin authoring our query, we also want to set the Query database to the New
York City taxi cab datasource we connected to earlier:

<img class="main-content__illustration" src="https://assets.iobeam.com/images/docs/screenshots-for-grafana-tutorial/set_data_source.png" alt="Switching data sources in Grafana"/>

### ~~Visualize metrics stored in TimescaleDB~~ (already done)

Let's start by creating a visualization that answers the question **How many rides took place on each day?**
from the [NYC Taxi Cab][nyc-taxi] tutorial.

From the tutorial, you can see the standard SQL syntax for our query:

```sql
SELECT date_trunc('day', pickup_datetime) AS day,
  COUNT(*)
FROM rides
GROUP BY day
ORDER BY day;
```

We will need to alter this query to support Grafana's unique query syntax.

#### ~~Modifying the SELECT statement~~ (already done)

First, we will modify the `date_trunc` function to use the TimescaleDB `time_bucket`
function. You can consult the TimescaleDB [API Reference on time_bucket][time-bucket-reference]
for more information on how to use it properly.

Let's examine the `SELECT` portion of this query. First, we will bucket our results into
one day groupings using the `time_bucket` function. If you set the 'Format' of a Grafana
panel to be 'Time series', for use in Graph panel for example, then the query must return
a column named `time` that returns either a SQL `datetime` or any numeric datatype
representing a Unix epoch.

So, part 1 of this new query is modified so that the output of the `time_bucket` grouping
is labeled `time` as Grafana requires, while part 2 is unchanged:

```sql
SELECT
  --1--
  time_bucket('1 day', pickup_datetime) AS "time",
  --2--
  COUNT(*)
FROM rides
```

#### ~~The Grafana \_\_timeFilter function~~ (already done)

Grafana time-series panels include a tool that enables the end-user to filter on a given
time range. A "time filter", if you will. Not surprisingly, Grafana has a way to link the
user interface construct in a Grafana panel with the query itself. In this case,
the `$__timefilter()` function.

In the modified query below, we will use the `$__timefilter()` function
to set the `pickup_datetime` column as the filtering range for our visualizations.

```sql
SELECT
  --1--
  time_bucket('1 day', pickup_datetime) AS "time",
  --2--
  COUNT(*)
FROM rides
WHERE $__timeFilter(pickup_datetime)
```

#### ~~Referencing elements in our query~~ (already done)

Finally, we want to group our visualization by the time buckets we've selected,
and we want to order the results by the time buckets as well. So, our `GROUP BY`
and `ORDER BY` statements will reference `time`.

With these changes, this is our final Grafana query:

```sql
SELECT
  --1--
  time_bucket('1 day', pickup_datetime) AS time,
  --2--
  COUNT(*)
FROM rides
WHERE $__timeFilter(pickup_datetime)
GROUP BY time
ORDER BY time
```

When we visualize this query in Grafana, we see the following:

<img class="main-content__illustration" src="https://assets.iobeam.com/images/docs/screenshots-for-grafana-tutorial/grafana_query_results.png" alt="Visualizing time-series data in Grafana"/>

<highlight type="tip">
 Remember to set the time filter in the upper right corner of your Grafana dashboard.
 If you're using the pre-built sample dataset for this example, you will want to set
 your time filter around January 1st, 2016.
</highlight>

Currently, the data is bucketed into 1 day groupings. Adjust the `time_bucket`
function to be bucketed into 5 minute groupings instead and compare the graphs:

```sql
SELECT
  --1--
  time_bucket('5m', pickup_datetime) AS time,
  --2--
  COUNT(*)
FROM rides
WHERE $__timeFilter(pickup_datetime)
GROUP BY time
ORDER BY time
```

When we visualize this query, it will look like this:

<img class="main-content__illustration" src="https://assets.iobeam.com/images/docs/screenshots-for-grafana-tutorial/grafana_query_results_5m.png" alt="Visualizing time-series data in Grafana"/>

### ~~Build a geospatial query~~ (already done)

The NYC Taxi Cab data also contains the location of each ride pickup. In the
[NYC Taxi Cab][nyc-taxi] tutorial, we examined rides that originated
near Times Square. Let's build on that query and
**visualize rides whose distance traveled was greater than five miles in Manhattan**.

We can do this in Grafana using the 'Worldmap Panel'. We will start by creating a
new panel, selecting 'New Visualization', and selecting the 'Worldmap Panel'.

Once again, we will edit our query directly. In the Query screen, be sure
to select your NYC Taxicab Data as the data source. In the 'Format as' dropdown,
select 'Table'. Click on 'Edit SQL' and enter the following query in the text window:

```sql
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
```

Let's dissect this query. First, we're looking to plot rides with visual markers that
denote the trip distance. Trips with longer distances will get different visual treatments
on our map. We will use the `trip_distance` as the value for our plot. We will store
this result in the `value` field.

In the second and third lines of the `SELECT` statement, we are using the `pickup_longitude`
and `pickup_latitude` fields in the database and mapping them to variables `longitude`
and `latitude`, respectively.

In the `WHERE` clause, we are applying a geospatial boundary to look for trips within
2000m of Times Square.

Finally, in the `GROUP BY` clause, we supply the `trip_distance` and location variables
so that Grafana can plot data properly.

<highlight type="warning">
 This query may take a while, depending on the speed of your Internet connection. This
 is why we're using the `LIMIT` statement for demonstration purposes.
</highlight>

### ~~Configure the worldmap Grafana panel~~ (already done)

Now let's configure our Worldmap visualization. Select the 'Visualization' tab in the far
left of the Grafana user interface. You'll see options for 'Map Visual Options', 'Map Data Options',
and more.

First, make sure the 'Map Data Options' are set to 'table' and 'current'.  Then in
the 'Field Mappings' section. We will set the 'Table Query Format' to be ‘Table'.
We can map the 'Latitude Field' to our `latitude` variable, the 'Longitude Field' to
our `longitude` variable, and the 'Metric' field to our `value` variable.

In the 'Map Visual Options', set the 'Min Circle Size' to 1 and the 'Max Circle Size' to 5.

In the 'Threshold Options' set the 'Thresholds' to '2,5,10'. This will auto configure a set
of colors. Any plot whose `value` is below 2 will be a color, any `value` between 2 and 5 will
be another color, any `value` between 5 and 10 will be a third color, and any `value` over 10
will be a fourth color.

Your configuration should look like this:

<img class="main-content__illustration" src="https://assets.iobeam.com/images/docs/screenshots-for-grafana-tutorial/grafana-fieldmapping.png" alt="Mapping Worldmap fields to query results in Grafana"/>

At this point, data should be flowing into our Worldmap visualization, like so:

<img class="main-content__illustration" src="https://assets.iobeam.com/images/docs/screenshots-for-grafana-tutorial/grafana_worldmap_query_results.png" alt="Visualizing time series data in PostgreSQL using the Grafana Worldmap"/>

You should be able to edit the time filter at the top of your visualization to see trip pickup data
for different timeframes.

### Summary

Complete your Grafana knowledge by following [all the TimescaleDB + Grafana tutorials][tutorial-grafana].

[install-timescale]: https://docs.timescale.com/timescaledb/latest/how-to-guides/install-timescaledb/
[install-grafana]: https://docs.timescale.com/timescaledb/latest/tutorials/grafana/installation/
[getting-started]: https://docs.timescale.com/timescaledb/latest/getting-started/
[nyc-taxi]: https://docs.timescale.com/timescaledb/latest/tutorials/nyc-taxi-cab/
[tutorial-grafana]: https://docs.timescale.com/timescaledb/latest/tutorials/grafana/
