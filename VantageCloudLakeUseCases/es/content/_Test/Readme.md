Introducción:
=============

Las bicicletas compartidas se están convirtiendo en un medio de transporte alternativo muy popular. Supongamos que tiene una empresa de transporte que presta servicios al público con varias estaciones en las que pueden acceder a sus servicios de transporte. Debe asegurarse de tener equipos en las estaciones cuando el público los necesite. También sabe que el clima afecta drásticamente la demanda de sus servicios de transporte. Esta demostración muestra cómo integrar información histórica de viajes con información meteorológica, aprovechando las capacidades de Vantage Geospatial y de series temporales para mejorar su servicio y hacer crecer su negocio.

La ciudad de Austin pone a disposición datos sobre \>649 000 viajes en bicicleta entre 2013 y 2017.

Contenido:
----------

-   Conectarse a Vantage
-   Explorar los datos
-   Crear y explorar datos de índices Temporal, geoespaciales y de tiempo
-   Estadísticas
-   Limpiar

1. Conectarse a Vantage
=======================

Abra el editor para continuar con este caso de uso. [INICIAR EDITOR](#data=%7B%22navigateTo%22:%22editor%22%7D)

1.1 Obtención de datos para esta demostración
---------------------------------------------

Seleccione **Cargar activos** para crear las tablas y cargar los datos necesarios en su cuenta (instancia de base de datos de Teradata) para este caso de uso.

[Cargar activos](#data=%7B%22id%22:%22New%22%7D)

Hemos proporcionado datos para esta demostración en el almacenamiento en la nube. Puede ejecutar la demostración utilizando tablas externas para acceder a los datos sin ningún almacenamiento en su entorno o descargar los datos al almacenamiento local, lo que puede generar una ejecución más rápida. Aun así, puede haber consideraciones sobre el almacenamiento disponible. Hay dos declaraciones en la siguiente celda y una de ellas está comentada. Puede cambiar entre los modos modificando la cadena de comentarios.

    -- call get_data('DEMO_AustinBikeShare_cloud');           -- Takes 20 seconds
    call get_data('DEMO_AustinBikeShare_local');           -- Takes 50 seconds

Paso opcional: si desea ver el estado de las bases de datos/tablas creadas y el espacio utilizado.

    call space_report();

2. Explorar los datos
=====================

A modo de calentamiento, veamos las tablas de nuestra base de datos TRNG\_AustinBike.

```sql
SELECT 
    DatabaseName,
    TableName
FROM
    DBC.Tables
WHERE
    DatabaseName = 'DEMO_AustinBikeShare'
```

Podemos ver que tenemos tres tablas en nuestra base de datos. La tabla Viajes contiene datos sobre los viajes realizados en bicicleta, la tabla Estaciones contiene las ubicaciones de las estaciones de bicicletas y la tabla Clima contiene detalles sobre el clima.

La siguiente consulta muestra el número de filas en cada una de las tablas de la base de datos.

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
```

2.1 Examinar la tabla de viajes
-------------------------------

Veamos los datos de muestra en la tabla de viajes.

```sql
SELECT
    *
FROM
    DEMO_AustinBikeShare.trips
SAMPLE 10;
```

¿Qué tipo de suscriptores realizan la mayoría de los viajes?

```sql
select top 10 count(trip_id) as ride_count, subscriber_type from DEMO_AustinBikeShare.trips group by subscriber_type order by 1 desc;
```

Del resultado anterior podemos decir que los viajes **sin reserva** son un 250 % más que el segundo tipo de suscripción más popular.

¿Desde qué estación parten el mayor número de viajes?

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
```

Vemos que **Riverside @ S. Lamar** tiene el mayor número de viajes originados desde aquí.

Veamos el número promedio de viajes que se originan desde una estación.

```sql
SELECT AVG(trips) FROM (
    SELECT
    start_station_name,
    COUNT(1) AS trips
    FROM
        DEMO_AustinBikeShare.trips
    GROUP BY 1
) AS t;
```

Vemos que la estación superior\*\* Riverside @ S. Lamar\*\* tiene 4 veces más viajes que el promedio.

Ahora veamos el patrón de uso de la bicicleta a lo largo del tiempo.

```sql
SELECT
    TRUNC(start_time, 'Month') AS start_Month,
    COUNT(1) AS trips
FROM
    DEMO_AustinBikeShare.trips
GROUP BY 1
ORDER BY 1;
%chart start_Month, trips, title = "Trips by day", typex = t, width = 700
```

En el gráfico anterior observamos algunas cosas:

-   Hay dos meses en los que los datos prácticamente faltan.
-   El mes de mayor uso es de hasta 30 000 viajes al mes.
-   Marzo y octubre son el primer y segundo mes de mayor actividad según los datos de 4 años.

¿Puede esto estar relacionado con el clima? ¿El clima en marzo y octubre es favorable para andar en bicicleta? Veámoslo en la siguiente sección.

2.2 Examinar la tabla meteorológica
-----------------------------------

```sql
SELECT * FROM DEMO_AustinBikeShare.weather SAMPLE 10;
```

Los datos de temperatura se notifican cada hora (los minutos y segundos siempre son cero). Las columnas de temperatura están en grados Kelvin, que pocas personas utilizan para decidir si hace buen tiempo para andar en bicicleta, por lo que crearemos una vista sobre la tabla meteorológica para convertir la temperatura a grados Fahrenheit. También calcularemos el promedio de la temperatura del día.

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
```

Si graficamos los datos, nos damos cuenta de que faltan algunos, pero obtenemos una idea de los rangos de temperatura típicos. Si observamos las horas de cada mes en las que se producen precipitaciones, vemos algunos patrones que también podrían estar afectando a la cantidad de viajes.

%chart dt, avetemp, width = 800, title = “Temperatura media por mes” Aquí podemos observar que, durante casi todos los meses de marzo y octubre, la temperatura ronda los 70 grados Fahrenheit. Esta es una temperatura favorable para andar en bicicleta, ya que no hace ni demasiado frío ni demasiado calor.

%chart dt, Precip\_hours, width = 800, title = “Horas de precipitación promedio por mes” En los dos gráficos anteriores, marzo y octubre tienen condiciones favorables para andar en bicicleta, lo que se refleja en un aumento de paseos en bicicleta.

2.3 Datos geoespaciales
-----------------------

Las columnas geoespaciales tienen un tipo y uno o más pares de latitud y longitud. Incluimos las columnas de latitud y longitud en la tabla para que pueda ver cómo se representa una característica geoespacial simple (un PUNTO). Para conocer más tipos de datos geoespaciales compatibles con Teradata, haga clic aquí.

```sql
SELECT * FROM DEMO_AustinBikeShare.stations SAMPLE 5;
```

Existen numerosas funciones geoespaciales, pero podemos demostrar lo básico encontrando la distancia desde la oficina principal (station\_id = 1001) hasta otras estaciones.

Para obtener más funciones geoespaciales compatibles con Teradata, haga clic aquí.

```sql
SELECT
    TOP 10 station.station_id, station.name, 
    ROUND(office.location.ST_SphericalDistance(station.location), 0) Distance_Meters
FROM DEMO_AustinBikeShare.stations station, DEMO_AustinBikeShare.stations office
WHERE office.station_id = 1001
ORDER BY 1;
```

3. Crear y explorar datos de índices Temporal, geoespaciales y de tiempo
========================================================================

3.1 Crear una tabla temporal con datos meteorológicos
-----------------------------------------------------

Las tablas temporales almacenan y mantienen información relativa al tiempo. Mediante el uso de tablas temporales, Vantage puede procesar instrucciones y consultas que incluyen razonamiento basado en el tiempo. Las tablas temporales tienen una o dos columnas especiales que almacenan información sobre el tiempo:

Una columna de tiempo de transacción registra y mantiene el período en el que Vantage tuvo conocimiento de la información en la fila. Vantage introduce y mantiene automáticamente los datos de la columna de tiempo de transacción y, en consecuencia, realiza un seguimiento del historial de dicha información. Una columna de tiempo válido modela el mundo real y almacena información como el tiempo de validez de una póliza de seguro o garantía de producto, la duración del empleo de una persona u otra información que es importante rastrear y manipular con conciencia del tiempo. Cuando agrega una nueva fila a este tipo de tabla, utiliza la columna de tiempo válido para especificar el período de tiempo durante el cual la información de la fila es válida. Este es el período de validez (PV) de la información en la fila.

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
```

Aquí, convertimos temp, temp\_min y temp\_max de Kelvin a Fahrenheit mientras insertamos los datos en la tabla weather\_temporal.

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
```

Ahora podemos responder de manera más rápida y eficiente a consultas de razonamiento basadas en el tiempo con tablas temporales. Por ejemplo, ¿el clima fue favorable para andar en bicicleta en marzo y octubre de 2016?

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
```

Los gráficos anteriores sugieren que marzo y octubre de 2016 tuvieron más días favorables para andar en bicicleta (despejado, nublado, con niebla), lo que explica el mayor número de paseos en bicicleta.

3.2 Crear una vista para todos los viajes con datos de estaciones de inicio/fin y una GEOSECUENCIA con latitud/longitud/hora de inicio/fin
------------------------------------------------------------------------------------------------------------------------------------------

El código a continuación define una vista que mejora los datos del viaje con un campo Geosecuencia que contiene la ubicación y la hora de los puntos de inicio y finalización del viaje.

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
```

3.3 Crear una tabla de índice de tiempo de los viajes para acelerar el análisis relacionado con el tiempo
---------------------------------------------------------------------------------------------------------

Vantage admite tablas con un índice de tiempo primario (PTI), que se utiliza para almacenar y buscar rápidamente datos que llegan en función del tiempo. Este índice, que tiene en cuenta el tiempo, distribuye los datos entre las unidades de paralelismo. Aun así, permite al optimizador crear planes que van directamente a la unidad de paralelismo donde se almacenan los datos en función de la restricción de tiempo.

En este caso, declararemos que el índice tiene granularidad horaria con una hora de referencia anterior a cualquier fecha de datos que tengamos. Según la declaración del índice principal, la base de datos crea automáticamente la primera columna con el nombre TD\_TIMECODE. Cuando insertemos datos, utilizaremos la columna start\_time como ese valor.

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
```

Ahora completamos la tabla local. Puede que tarde un minuto en obtener los datos del almacenamiento en la nube.

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
```

3.4 Aumentar los datos de los viajes con datos meteorológicos y extraer información geoespacial
-----------------------------------------------------------------------------------------------

Finalmente, unimos los datos con la información del viaje de geosecuencia con los datos meteorológicos disponibles, donde el período del informe meteorológico contiene la hora de inicio del viaje (TD\_TIMECODE).

Para obtener más funciones geoespaciales compatibles con Teradata, haga clic aquí.

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
```

4. Perspectivas
===============

4.1 Distancia media recorrida respecto de las estaciones de inicio
------------------------------------------------------------------

```sql
SELECT
    start_station_name, AVG(total_distance), COUNT(trip_id)
FROM trips_and_weather
GROUP BY start_station_name
ORDER BY 2 DESC;
```

La visualización anterior sugiere que la oficina principal tiene la distancia promedio más alta que recorren las personas. Aunque solo diez viajes se originan en la estación principal, sigue teniendo la distancia promedio más alta recorrida. Estos diez viajes son muy largos.

4.2 Efecto del clima en la distancia recorrida
----------------------------------------------

```sql
SELECT
    TOP 10 SUM(total_distance) AS distance_km, subscriber_type, weather_main
FROM trips_and_weather
GROUP BY subscriber_type, weather_main
ORDER BY 1 DESC;
```

Al observar los resultados anteriores, los suscriptores sin reserva, local365 y local30 viajaron más distancia cuando el clima estaba despejado o nublado.

4.3 Duración promedio del viaje con respecto al tipo de suscriptor y al tipo de viaje
-------------------------------------------------------------------------------------

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
```

Al observar los resultados anteriores, los viajes de ida y vuelta son más largos que los de punto a punto para los miembros que están explorando, los que no tienen reserva o los miembros anuales.

4.4 ¿La bicicleta requiere mantenimiento?
-----------------------------------------

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
```

Observando los resultados anteriores, 50 bicicletas requieren mantenimiento según nuestra suposición de que debemos realizar reparaciones de bicicletas cada 70 km.

5. Limpiar
==========

5.1 Tablas de trabajo
---------------------

Limpie las tablas de trabajo para evitar errores la próxima vez. En esta sección se eliminan todas las tablas creadas durante la demostración.

```sql
DROP TABLE weather_temporal;
DROP TABLE trips_geo_pti;
DROP TABLE trips_and_weather;
DROP VIEW trips_geo;
```

5.2 Bases de datos y tablas
---------------------------

El siguiente código limpiará las tablas y bases de datos creadas anteriormente.

```sql
call remove_data('DEMO_AustinBikeShare')
```

Enlaces:
========

Puede encontrar información sobre el tipo de datos geoespaciales aquí. Puede encontrar información sobre el tipo de datos temporales aquí.
