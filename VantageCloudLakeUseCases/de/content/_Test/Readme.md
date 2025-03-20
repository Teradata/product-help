Einführung:
===========

Leihfahrräder werden zu einer beliebten alternativen Transportmöglichkeit. Nehmen wir an, Sie hätten ein Transportunternehmen, das der Öffentlichkeit verschiedene Stationen zur Verfügung stellt, an denen sie Ihre Transportdienste in Anspruch nehmen kann. Sie müssen sicherstellen, dass Sie die Ausrüstung an den Stationen haben, wenn der Bedarf besteht. Sie wissen auch, dass das Wetter die Nachfrage nach Ihren Mobilitätsdienstleistungen stark beeinflusst. Diese Demonstration zeigt, wie Sie historische Fahrtdaten mit Wetterinformationen kombinieren und dabei die Funktionen von Vantage Geospatial und Zeitreihen nutzen können, um Ihren Service zu verbessern und Ihr Geschäft auszubauen.

Die Stadt Austin stellt Daten zu über 649.000 Fahrradfahrten im Zeitraum 2013–2017 zur Verfügung.

Inhalt:
-------

-   Mit Vantage verbinden
-   Daten untersuchen
-   Temporäre, Geo- und Zeitindexdaten erstellen und untersuchen
-   Einblicke
-   Bereinigen

1. Mit Vantage verbinden
========================

Öffnen Sie den Editor, um mit diesem Anwendungsfall fortzufahren. [EDITOR STARTEN](#data=%7B%22navigateTo%22:%22editor%22%7D)

1.1 Abrufen von Daten für diese Demo
------------------------------------

Wählen Sie **Objekte laden** aus, um die Tabellen zu erstellen und die für diesen Anwendungsfall erforderlichen Daten in Ihr Konto (Teradata-Datenbankinstanz) zu laden.

[Objekte laden](#data=%7B%22id%22:%22New%22%7D)

Wir haben Daten für diese Demo im Cloud-Speicher bereitgestellt. Sie können die Demo entweder mit Fremdtabellen ausführen, um auf die Daten zuzugreifen, ohne dass diese in Ihrer Umgebung gespeichert werden, oder die Daten in den lokalen Speicher herunterladen, wodurch die Ausführung möglicherweise beschleunigt wird. Dennoch kann es Überlegungen zum verfügbaren Speicher geben. In der folgenden Zelle befinden sich zwei Anweisungen, und eine davon ist auskommentiert. Sie können zwischen den Modi wechseln, indem Sie die Kommentarzeichenfolge ändern.

    -- call get_data('DEMO_AustinBikeShare_cloud');           -- Takes 20 seconds
    call get_data('DEMO_AustinBikeShare_local');           -- Takes 50 seconds

Optionaler Schritt – wenn Sie den Status der erstellten Datenbanken/Tabellen und den verwendeten Speicherplatz anzeigen möchten.

    call space_report();

2. Daten untersuchen
====================

Lassen Sie uns zunächst einen Blick auf die Tabellen in unserer Datenbank TRNG\_AustinBike werfen.

```sql
SELECT 
    DatabaseName,
    TableName
FROM
    DBC.Tables
WHERE
    DatabaseName = 'DEMO_AustinBikeShare'
```

Wir sehen, dass wir drei Tabellen in unserer Datenbank haben. Die Tabelle „Fahrten“ enthält Daten zu den Fahrten, die mit den Fahrrädern unternommen wurden, die Tabelle „Stationen“ enthält die Standorte der Fahrradstationen und die Wettertabelle enthält Details zum Wetter.

Die folgende Abfrage zeigt die Anzahl der Zeilen in jeder der Tabellen in der Datenbank.

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

2.1 Tabelle „Fahrten“ untersuchen
---------------------------------

Schauen wir uns die Beispieldaten in der Tabelle „Fahrten“ an.

```sql
SELECT
    *
FROM
    DEMO_AustinBikeShare.trips
SAMPLE 10;
```

Welcher Abonnententyp unternimmt die meisten Fahrten?

```sql
select top 10 count(trip_id) as ride_count, subscriber_type from DEMO_AustinBikeShare.trips group by subscriber_type order by 1 desc;
```

Aus dem obigen Ergebnis können wir schließen, dass **Nach oben gehen**-Fahrten 250 % häufiger sind als der zweitbeliebteste Abonnementtyp.

Von welcher Station aus starten die meisten Fahrten?

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

Wir sehen, dass **Riverside @ S. Lamar** die höchste Anzahl von Fahrten hat, die von hier aus starten.

Sehen wir uns die durchschnittliche Anzahl der Fahrten an, die von einer Station aus starten.

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

Wir sehen, dass die obere Station Riverside @ S. Lamar viermal mehr Fahrten als der Durchschnitt verzeichnet.

Schauen wir uns nun das Muster der Fahrradnutzung in einem bestimmten Zeitraum an.

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

Im obigen Diagramm können wir einige Dinge beobachten:

-   Es gibt zwei Monate, in denen die Daten fast fehlen
-   Der monatliche Spitzenwert liegt bei bis zu 30.000 Fahrten
-   Gemäß den Daten der letzten vier Jahre sind der März und der Oktober die Monate mit den meisten und zweitmeisten Fahrten.

Kann das mit dem Wetter zusammenhängen? Ist das Wetter im März und Oktober günstig zum Radfahren? Das sehen wir uns im nächsten Abschnitt an.

2.2 Wettertabelle untersuchen
-----------------------------

```sql
SELECT * FROM DEMO_AustinBikeShare.weather SAMPLE 10;
```

Die Temperaturdaten werden stündlich gemeldet (Minuten und Sekunden sind immer null). Die Angaben zu den Temperaturen sind in Kelvin, was nur wenige Menschen als Entscheidungsgrundlage für gutes Fahrradwetter heranziehen. Wir erstellen also eine Ansicht über die Wettertabelle, um die Temperatur in Fahrenheit umzurechnen. Wir werden auch die Durchschnittstemperatur für den Tag ermitteln.

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

Wenn wir die Daten grafisch darstellen, stellen wir fest, dass einige Daten fehlen. Wir erhalten jedoch eine Vorstellung von den typischen Temperaturbereichen. Wenn wir uns die Stunden jeden Monats ansehen, in denen es Niederschläge gibt, erkennen wir einige Muster, die sich auch auf die Anzahl der Fahrten auswirken könnten.

%chart dt, avetemp, width = 800, title = „Durchschnittstemperatur nach Monat“. Hier können wir beobachten, dass die Temperatur in fast dem gesamten Monat März und Oktober bei etwa 21 °C liegt. Das ist eine angenehme Temperatur zum Radfahren, da es weder zu kalt noch zu heiß ist.

%chart dt, Precip\_hours, width = 800, title = „Durchschnittliche Niederschlagsstunden pro Monat“. Aus den beiden obigen Diagrammen geht hervor, dass im März und Oktober günstige Bedingungen für das Radfahren herrschen, was sich in der Zunahme der Radtouren widerspiegelt.

2.3 Geodaten
------------

Die Geodaten-Spalten enthalten einen Typ und ein oder mehrere Paare aus Längen- und Breitengraden. Wir haben die Breitengrad- und Längengradspalten in die Tabelle aufgenommen, damit Sie sehen können, wie ein einfaches Geodatenmerkmal (ein PUNKT) dargestellt wird. Weitere von Teradata unterstützte Geodatentypen finden Sie hier.

```sql
SELECT * FROM DEMO_AustinBikeShare.stations SAMPLE 5;
```

Es gibt zahlreiche Geodatenfunktionen, aber wir können die Grundlagen demonstrieren, indem wir die Entfernung vom Hauptbüro (station\_id = 1001) zu anderen Stationen ermitteln.

Klicken Sie hier, um weitere von Teradata unterstützte Geodatenfunktionen anzuzeigen.

```sql
SELECT
    TOP 10 station.station_id, station.name, 
    ROUND(office.location.ST_SphericalDistance(station.location), 0) Distance_Meters
FROM DEMO_AustinBikeShare.stations station, DEMO_AustinBikeShare.stations office
WHERE office.station_id = 1001
ORDER BY 1;
```

3. Temporäre, Geo- und Zeitindexdaten erstellen und untersuchen
===============================================================

3.1 Zeittabelle mit Wetterdaten erstellen
-----------------------------------------

Zeittabellen speichern und verwalten Informationen zur Zeit. Mithilfe von Zeittabellen kann Vantage Anweisungen und Abfragen verarbeiten, die zeitbasierte Schlussfolgerungen enthalten. Zeittabellen haben eine oder zwei spezielle Spalten, in denen Zeitinformationen gespeichert werden:

In einer Spalte für die Transaktionszeit wird der Zeitraum aufgezeichnet und gepflegt, in dem Vantage die Informationen in der Zeile bekannt waren. Vantage gibt die Spaltendaten für die Transaktionszeit automatisch ein und pflegt sie. Dadurch wird der Verlauf dieser Informationen nachverfolgt. Eine Spalte mit Gültigkeitszeitpunkten modelliert die reale Welt und speichert Informationen wie die Gültigkeitsdauer einer Versicherungspolice oder Produktgarantie, die Beschäftigungsdauer eines Mitarbeiters oder andere Informationen, die wichtig sind, um sie mit zeitlicher Genauigkeit zu verfolgen und zu bearbeiten. Wenn Sie eine neue Zeile zu dieser Art von Tabelle hinzufügen, verwenden Sie die Gültigkeitszeitspalte, um den Zeitraum anzugeben, für den die Zeileninformationen gültig sind. Dies ist die Gültigkeitsdauer (PV) der Informationen in der Zeile.

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

Hier konvertieren wir temp, temp\_min und temp\_max von Kelvin in Fahrenheit, während wir die Daten in die Tabelle weather\_temporal einfügen.

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

Jetzt können wir zeitbasierte Argumentationsanfragen schneller und effizienter mit Zeittabellen beantworten. War das Wetter im März und Oktober 2016 beispielsweise günstig zum Radfahren?

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

Die obigen Grafiken lassen darauf schließen, dass es im März und Oktober 2016 mehr Tage gab, die sich zum Radfahren eigneten (klar, bewölkt, Nebel), was die gestiegene Zahl der Radtouren erklärt.

3.2 Eine Ansicht für alle Fahrten mit Start-/Endstationsdaten und einer GEOSEQUENZ mit Start-/End-Längen-/Breitengraden/Zeit erstellen
--------------------------------------------------------------------------------------------------------------------------------------

Der folgende Code definiert eine Ansicht, die die Fahrtdaten mit einem Geosequenz-Feld erweitert, das den Ort und die Zeit für den Start- und Endpunkt der Fahrt enthält.

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

3.3 Eine Zeitindex-Tabelle der Fahrten erstellen, um zeitbezogene Analysen zu beschleunigen
-------------------------------------------------------------------------------------------

Vantage unterstützt Tabellen mit einem Primary Time Index (PTI), der zum Speichern und schnellen Nachschlagen zeitabhängiger Daten verwendet wird. Dieser zeitabhängige Index verteilt Daten auf die Parallelitätseinheiten. Dennoch ermöglicht er der Optimierung, Pläne zu erstellen, die direkt zur Parallelitätseinheit gehen, in der die Daten basierend auf der Zeitbeschränkung gespeichert sind.

In diesem Fall erklären wir den Index als stundengenau mit einer Basiszeit, die vor allen uns vorliegenden Datumsangaben liegt. Basierend auf der primären Indexdeklaration erstellt die Datenbank automatisch die erste Spalte mit dem Namen TD\_TIMECODE. Wenn wir Daten einfügen, verwenden wir die Spalte „start\_time“ als diesen Wert.

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

Wir füllen jetzt die lokale Tabelle. Das Abrufen der Daten aus dem Cloud-Speicher kann eine Minute dauern.

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

3.4 Fahrtdaten mit Wetterdaten ergänzen und Geodaten extrahieren
----------------------------------------------------------------

Abschließend führen wir die Daten mit den Geosequenz-Fahrtdaten und den vorhandenen Wetterdaten zusammen, wobei der Wetterberichtszeitraum den Startzeitpunkt der Fahrt (TD\_TIMECODE) enthält.

Klicken Sie hier, um weitere von Teradata unterstützte Geodatenfunktionen anzuzeigen.

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

4. Einblicke
============

4.1 Durchschnittliche zurückgelegte Distanz ab Startstationen
-------------------------------------------------------------

```sql
SELECT
    start_station_name, AVG(total_distance), COUNT(trip_id)
FROM trips_and_weather
GROUP BY start_station_name
ORDER BY 2 DESC;
```

Die obige Visualisierung lässt darauf schließen, dass die Hauptniederlassung die höchste durchschnittliche Entfernung aufweist, die die Menschen zurücklegen. Obwohl nur zehn Fahrten von der Hauptstation ausgehen, weist diese dennoch die höchste durchschnittliche zurückgelegte Entfernung auf. Diese zehn Fahrten sind sehr lang.

4.2 Einfluss des Wetters auf die zurückgelegte Strecke
------------------------------------------------------

```sql
SELECT
    TOP 10 SUM(total_distance) AS distance_km, subscriber_type, weather_main
FROM trips_and_weather
GROUP BY subscriber_type, weather_main
ORDER BY 1 DESC;
```

Betrachtet man die obigen Ergebnisse, so legten Walk-up-, local365- und local30-Abonnenten bei klarem oder bewölktem Wetter mehr Strecke zurück.

4.3 Durchschnittliche Fahrtdauer nach Art des Abonnenten und Art der Fahrt
--------------------------------------------------------------------------

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

Betrachtet man die Ergebnisse oben, sind die Hin- und Rückfahrten für Explorer-, Walk-up- und Jahresmitglieder länger als die Punkt-zu-Punkt-Fahrten.

4.4 Ist für das Fahrrad eine Wartung erforderlich?
--------------------------------------------------

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

Betrachtet man die Ergebnisse oben, müssen 50 Fahrräder gewartet werden, da wir davon ausgehen, dass wir alle 70 km eine Reparatur durchführen sollten.

5. Bereinigen
=============

5.1 Arbeitstabellen
-------------------

Bereinigen Sie Arbeitstabellen, um beim nächsten Mal Fehler zu vermeiden. In diesem Abschnitt werden alle während der Demonstration erstellten Tabellen gelöscht.

```sql
DROP TABLE weather_temporal;
DROP TABLE trips_geo_pti;
DROP TABLE trips_and_weather;
DROP VIEW trips_geo;
```

5.2 Datenbanken und Tabellen
----------------------------

Der folgende Code bereinigt die oben erstellten Tabellen und Datenbanken.

```sql
call remove_data('DEMO_AustinBikeShare')
```

Links:
======

Informationen zum Geodatentyp finden Sie hier. Informationen zum Zeitdatentyp finden Sie hier.
