# Introduction:

Bike shares are becoming a popular alternative means of transportation. Suppose you had a transportation business servicing the public with various stations where they could access your transportation services. You must ensure you have equipment at the stations when the public needs them. You also know that the weather dramatically impacts the demand for your transportation services. This demonstration shows how to integrate historical trip information with weather information, leveraging Vantage Geospatial and time-series capabilities to improve your service and grow your business.

The City of Austin makes data available on >649k bike trips over 2013-2017.

## Contents:

- Connect to Vantage
- Explore the data
- Create and Explore Temporal, Geospatial and Time index data
- Insights
- Clean up

# 1. Connect to Vantage
Open Editor to proceed with this use case.
[LAUNCH EDITOR](#data={"navigateTo":"editor"})

## 1.1 Getting Data for This Demo


Select **Load Assets** to create the tables and load the data required into your account (Teradata database instance) for this use case.

[Load Assets](#data={"id":"New"})


We have provided data for this demo on cloud storage. You can either run the demo using foreign tables to access the data without any storage on your environment or download the data to local storage, which may yield faster execution. Still, there could be considerations of available storage. Two statements are in the following cell, and one of them is commented out. You may switch between the modes by changing the comment string.
````
-- call get_data('DEMO_AustinBikeShare_cloud');           -- Takes 20 seconds
call get_data('DEMO_AustinBikeShare_local');           -- Takes 50 seconds
````
Optional step – if you want to see status of databases/tables created and space used.

````
call space_report();
````

# 2. Explore the data
As a warm-up, let us look at the tables in our database TRNG_AustinBike.
```sql
SELECT 
    DatabaseName,
    TableName
FROM
    DBC.Tables
WHERE
    DatabaseName = 'DEMO_AustinBikeShare'
```
We can see that we have three tables in our database. The Trips table contains data on the trips taken using the bikes, the stations table has locations of the bike stations, and the weather table has details about the weather.

The query below shows the number of rows in each of the tables in the database.
```sql
SELECT
(
    SELECT COUNT(*)
    FROM DEMO_AustinBikeShare.trips
) AS trips,
(
    SELECT COUNT(*)
    FROM DEMO_AustinBikeShare.stations
) AS stations,
(
    SELECT COUNT(*)
    FROM DEMO_AustinBikeShare.weather
) AS weather;
````
## 2.1 Examine the trips table

Let's look at the sample data in the trips table.
```sql
SELECT
    *
FROM
    DEMO_AustinBikeShare.trips
SAMPLE 10;
````
Which type of subscribers take most of the rides?
```sql
select top 10 count(trip_id) as ride_count, subscriber_type from DEMO_AustinBikeShare.trips group by subscriber_type order by 1 desc;
````
From the above result we can say that **Walk Up** rides are 250% more than second most popular subscription type.

From which station do highest number of trips start?
```sql
SELECT
    TOP 20
    start_station_name,
    COUNT(trip_id) AS trips
FROM
    DEMO_AustinBikeShare.trips
GROUP BY 1
ORDER BY 2 DESC;
%chart start_station_name, trips, title = "Trips by station", height = 200, width = 700
````
We see that **Riverside @ S. Lamar** has the highest number of trips originating from here.

Let's see average number of trips originating per from a station.
```sql
SELECT AVG(trips) FROM (
    SELECT
    start_station_name,
    COUNT(1) AS trips
    FROM
        DEMO_AustinBikeShare.trips
    GROUP BY 1
) AS t;
````
We see that the top station** Riverside @ S. Lamar** has 4 times more trips than the average.

Now let's look at the pattern of bike usage over time.
```sql
SELECT
    TRUNC(start_time, 'Month') AS start_Month,
    COUNT(1) AS trips
FROM
    DEMO_AustinBikeShare.trips
GROUP BY 1
ORDER BY 1;
%chart start_Month, trips, title = "Trips by day", typex = t, width = 700
````
In the above chart we observe few things:

- There are two months where the data is nearly missing
- The peak usage month is as much as 30k trips in a month
- March and October are first and second busiest months across the data of 4 years.

Can this be related to the weather? Is the weather in March and October favorable for biking? Let's see this in the next section.

## 2.2 Examine the weather table
```sql
SELECT * FROM DEMO_AustinBikeShare.weather SAMPLE 10;
````
The temperature data is reported hourly (the minutes and seconds are always zero). The temperature columns are in Kelvin, which few people use to decide if it is good bicycle weather, so we will create a view over the weather table to convert the temperature to Fahrenheit. We will also average the temperature for the day.
```sql
REPLACE VIEW austin_weather AS
    SELECT
        TRUNC(dt, 'Month') AS dt, 
        ROUND(AVG((temp - 273.15) * 9/5 + 32) ,0) AS AveTemp,
        SUM(CASE
                WHEN weather_main in ('Rain', 'Mist') THEN 1
                ELSE 0
            END) AS Precip_hours
    FROM DEMO_AustinBikeShare.weather
    GROUP BY 1;
SELECT * FROM austin_weather ORDER BY 1;
````
If we plot the data, we find we are missing some data, but we get an idea of the typical temperature ranges. If we look at the hours each month when precipitation occurs, we see some patterns that could also be impacting the number of trips.

%chart dt, avetemp, width = 800, title = "Average Temperature by Month"
Here we can observe that for almost all of the March and October months, the temperature is around 70 degrees Fahrenheit. This is a favorable biking temperature as it is neither too cold nor too hot.

%chart dt, Precip_hours, width = 800, title = "Average Precip Hours by Month"
From the above two charts, March and October have favorable conditions for biking, which reflects in the increased bike rides.

## 2.3 Geospatial data

The Geospatial columns have a type and one or more pairs of Latitude and Longitude. We included the Latitude and Longitude columns in the table so you could see how a simple geospatial feature (a POINT) is represented.
For more geospatial datatypes supported by Teradata, please click here.
```sql
SELECT * FROM DEMO_AustinBikeShare.stations SAMPLE 5;
````
Numerous geospatial functions exist, but we can demonstrate the basics by finding the distance from the main office (station_id = 1001) to other stations.

For more geospatial functions supported by Teradata, please click here.
```sql
SELECT
    TOP 10 station.station_id, station.name, 
    ROUND(office.location.ST_SphericalDistance(station.location), 0) Distance_Meters
FROM DEMO_AustinBikeShare.stations station, DEMO_AustinBikeShare.stations office
WHERE office.station_id = 1001
ORDER BY 1;
````
# 3. Create and Explore Temporal, Geospatial and Time index data
## 3.1 Create a temporal table with weather data

Temporal tables store and maintain information concerning time. Using temporal tables, Vantage can process statements and queries that include time-based reasoning. Temporal tables have one or two special columns which store time information:

A transaction-time column records and maintains the period Vantage was aware of the information in the row. Vantage automatically enters and maintains the transaction-time column data and consequently tracks such information's history.
A valid-time column models the real-world and stores information such as the time an insurance policy or product warranty is valid, the length of employment of an employee, or other information that is important to track and manipulate in a time-aware fashion. When you add a new row to this type of table, you use the valid-time column to specify the time period for which the row information is valid. This is the period of validity (PV) of the information in the row.
```sql
CREATE TABLE weather_temporal (
    begin_dt      TIMESTAMP(6) NOT NULL,
    end_dt        TIMESTAMP(6) NOT NULL,
    temp          FLOAT,
    temp_min      FLOAT,
    temp_max      FLOAT,
    pressure      INTEGER,
    humidity      INTEGER,
    wind_speed    INTEGER,
    wind_deg      INTEGER,
    rain_1h       FLOAT,
    rain_3h       FLOAT,
    clouds        INTEGER,
    weather_id    INTEGER,
    weather_main  VARCHAR(50),
    weather_desc  VARCHAR(50),
    weather_icon  VARCHAR(50),
    PERIOD FOR Weather_Duration(begin_dt,end_dt) AS VALIDTIME
)
PRIMARY INDEX (weather_id);
````
Here, we are converting temp, temp_min, and temp_max from Kelvin to Fahrenheit while inserting the data into the weather_temporal table.
```sql
INSERT INTO weather_temporal
SELECT
    dt,
    dt + INTERVAL '59' MINUTE + INTERVAL '59' SECOND,
    round( ((temp - 273.15) * 9/5 + 32 ) ,0),
    round( ((temp_min - 273.15) * 9/5 + 32 ) ,0),
    round( ((temp_max - 273.15) * 9/5 + 32 ) ,0),
    pressure,
    humidity,
    wind_speed,
    wind_deg,
    rain_1h,
    rain_3h,
    clouds,
    weather_id,
    weather_main,
    weather_desc,
    weather_icon
FROM 
    DEMO_AustinBikeShare.weather;
SEQUENCED VALIDTIME SELECT * FROM weather_temporal SAMPLE 10;
````
Now we can efficiently answer time-based reasoning queries faster and efficiently with Temporal tables. For example, was the weather favorable to biking in March and October 2016?
```sql
SELECT
    COUNT(weather_main) AS weather_hours, weather_main
FROM (
    VALIDTIME PERIOD '(2016-03-01, 2016-03-31)'
    SELECT * FROM weather_temporal
) AS dt
GROUP BY weather_main;
%chart weather_main, weather_hours, width = 500, title = "Duration(in hours) of weather by weather type(for March 2016)"
SELECT
    COUNT(weather_main) AS weather_hours, weather_main
FROM (
        VALIDTIME PERIOD '(2016-10-01, 2016-10-30)'
        SELECT * FROM weather_temporal
    ) AS dt
GROUP BY weather_main;
%chart weather_main, weather_hours, width = 500, title = "Duration(in hours) of weather by weather type(for October 2016)"
````
The above graphs suggest that March and October 2016 had more days favorable for biking(clear, cloudy, mist), hence explaining the increased number of bike rides.

## 3.2 Create a view for all trips with start/end stations data and a GEOSEQUENCE with start/end lat/long/time

The code below defines a view which enhances the trip data with a Geosequence field containing the location and time for the start and end points of the trip.
```sql
REPLACE VIEW trips_geo AS
SELECT
    t.bikeid,
    t.trip_ID,
    t.subscriber_type,
    t.start_station_id,
    COALESCE(t.start_station_name, st.NAME) AS start_station_name,
    t.start_time,
    st.status starting_station_status,
    t.end_station_id,
    COALESCE(t.end_station_name, ed.NAME) AS end_station_name,
    t.start_time 
        + CAST(t.duration_minutes/60 AS INTERVAL HOUR(4)) 
        + CAST(t.duration_minutes MOD 60 AS INTERVAL MINUTE(4)) AS end_time,
    ed.status AS End_station_status,
    t.duration_minutes,
    NEW ST_GEOMETRY('ST_POINT' ,st.Longitude, st.Latitude) AS start_location,
    NEW ST_GEOMETRY('ST_POINT' ,ed.Longitude, ed.Latitude) AS end_location,
    CAST('GEOSEQUENCE( ('
        || COALESCE(st.Longitude,-98.272797)
        || ' '
        || COALESCE(st.Latitude,30.578245)
        || ','
        || COALESCE(ed.longitude,-98.272797)
        || ' '
        || COALESCE(ed.latitude,30.578245)
        || '), ('
        || CAST(CAST(t.start_time AS FORMAT 'yyyy-mm-ddbhh:mi:ss') AS VARCHAR(50))
        || ','
        || CAST(CAST(end_time AS FORMAT 'yyyy-mm-ddbhh:mi:ss') AS VARCHAR(50))
        || '), ('
        || '1,2), (0) )' AS ST_GEOMETRY) AS GEOM
FROM
    DEMO_AustinBikeShare.trips AS t
    LEFT JOIN DEMO_AustinBikeShare.stations AS st ON t.start_station_id = st.station_id
    LEFT JOIN DEMO_AustinBikeShare.stations AS ed ON t.end_station_id = ed.station_id;
SELECT TOP 10 * FROM trips_geo;
````
## 3.3 Create a Time Index table of the trips to accelerate time related analysis

Vantage supports tables with a Primary Time Index (PTI), which is used to store and quickly look up data that arrives based on time. This time-aware index distributes data across the units of parallelism. Still, it allows the optimizer to build plans which go directly to the unit of parallelism where the data is stored based on the time constraint.

In this case, we will declare the index to have hourly granularity with a baseline time earlier than any date of data we have. Based on the primary index declaration, the database automatically creates the first column with the name TD_TIMECODE. When we insert data, we will use the start_time column as that value.
```sql
CREATE TABLE trips_geo_pti (
    bikeid                    INTEGER,
    trip_id                   BIGINT,
    subscriber_type           VARCHAR(50),
    start_station_id          INTEGER,
    start_station_name        VARCHAR(100),
    starting_station_status   VARCHAR(50),
    end_station_id            INTEGER,
    end_station_name          VARCHAR(100),
    end_time                  TIMESTAMP(6),
    end_station_status        VARCHAR(50),
    duration_minutes          INTEGER,
    geom                      SYSUDTLIB.ST_GEOMETRY(16776192) INLINE LENGTH 9920
)
PRIMARY TIME INDEX (TIMESTAMP(6), DATE '2013-12-20', MINUTES(60));
````
We now populate the local table. This could take a minute to get data from the cloud storage.
```sql
INSERT INTO trips_geo_pti
SELECT
    start_time,
    bikeid,
    trip_id,
    subscriber_type,
    start_station_id,
    start_station_name,
    starting_station_status,
    end_station_id,
    end_station_name,
    end_time,
    End_station_status,
    duration_minutes,
    geom
FROM
    trips_geo;
SELECT TOP 10 * FROM trips_geo_pti
````
## 3.4 Augment trips data with weather data and extract geospatial information

Finally, we bring the data together with the geosequence trip information with the available weather data, where the weather report period contains the trip's start time (TD_TIMECODE).

For more geospatial functions supported by Teradata, please click here.
```sql
CREATE TABLE trips_and_weather AS (
    SELECT 
        t.start_station_name,
        t.end_station_name,
        t.bikeid,
        t.trip_id,
        t.subscriber_type as subscriber_type,
        t.geom.GetInitT() AS pickup_time,
        t.geom.GetFinalT() AS dropoff_time,
        t.geom.ST_POINTN(1).ST_SPHEROIDALDISTANCE(geom.ST_POINTN(2))/1000 AS total_distance,
        t.geom.ST_POINTN(1).ST_X() AS pickup_location_lon,
        t.geom.ST_POINTN(1).ST_Y() AS pickup_location_lat,
        t.geom.ST_POINTN(2).ST_X() AS dropoff_location_lon,
        t.geom.ST_POINTN(2).ST_Y() AS dropoff_location_lat,        
        t.duration_minutes,
        t.TD_TIMECODE as Trip_TIMECODE,
        wt.*
    FROM 
        trips_geo_pti AS t
        INNER JOIN Weather_temporal AS wt ON wt.weather_duration CONTAINS t.TD_TIMECODE
        AND pickup_time >= '2017-07-01 00:00:00'
)
WITH DATA primary index(trip_id);
SELECT TOP 10 * FROM trips_and_weather WHERE CAST(pickup_time AS DATE) BETWEEN '2017-07-01' AND '2017-07-31'
````
# 4. Insights
## 4.1 Average distance traveled w.r.t start stations
```sql
SELECT
    start_station_name, AVG(total_distance), COUNT(trip_id)
FROM trips_and_weather
GROUP BY start_station_name
ORDER BY 2 DESC;
````
The above visualization suggests that Main Office has the highest average distance people travel. Even though only ten trips originate from the main station, it still has the highest average distance traveled. These ten trips are very long.

## 4.2 Effect of weather on distance traveled
```sql
SELECT
    TOP 10 SUM(total_distance) AS distance_km, subscriber_type, weather_main
FROM trips_and_weather
GROUP BY subscriber_type, weather_main
ORDER BY 1 DESC;
````
Looking at the results above, walk-up, local365, and local30 subscribers traveled more distance when the weather was clear or cloudy.

## 4.3 Average trip duration w.r.t subscriber type and trip type
```sql
SELECT
    subscriber_type,
    CASE
        WHEN start_station_name = end_station_name THEN 'Round_Trip'
        ELSE 'Point-to-Point'
    END AS trip_type,
    AVG(duration_minutes) AS time_mins
FROM trips_and_weather
GROUP BY subscriber_type, trip_type
ORDER BY 3 DESC;
````
Looking at the results above, round trips have longer trips than point-to-point for the explorer, walk up and annual members.

## 4.4 Does the bike require maintenance?
```sql
SELECT
    bikeid, COUNT(*) AS num_trips, sum(total_distance) AS distance,
    CASE
        WHEN distance > 70 THEN 'Recommended'
        ELSE 'Not Required'
    END AS maintenance
FROM trips_and_weather
GROUP BY bikeid
ORDER BY 3 DESC;
%chart maintenance, bikeid, aggregatey=count, width = 200, title="Maintenance Required?"
````
Looking at the results above, 50 bikes require maintenance according to our assumption that we should do bike repairs after every 70 kms.

# 5. Clean up
## 5.1 Work Tables

Cleanup work tables to prevent errors next time. This section drops all the tables created during the demonstration.
```sql
DROP TABLE weather_temporal;
DROP TABLE trips_geo_pti;
DROP TABLE trips_and_weather;
DROP VIEW trips_geo;
````
## 5.2 Databases and Tables

The following code will clean up tables and databases created above.
```sql
call remove_data('DEMO_AustinBikeShare')
```

# Links:

Information about Geospatial datatype can be found here
Information about Temporal datatype can be found here