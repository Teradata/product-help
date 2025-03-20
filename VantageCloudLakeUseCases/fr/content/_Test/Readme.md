Introduction :
==============

Les vélos en libre-service sont en train de devenir un moyen de transport alternatif populaire. Supposons que vous ayez une entreprise de transport au service du public avec plusieurs stations dans lesquelles les gens peuvent accéder à vos services de transport. Vous devez vous assurer que vous disposez d'équipements dans les stations lorsque le public en a besoin. Vous savez également que la météo a une incidence considérable sur la demande de vos services de transport. Cette démonstration montre comment intégrer les informations historiques sur les voyages aux informations météorologiques, en tirant parti des fonctionnalités géospatiales et de séries chronologiques de Vantage pour améliorer votre service et développer votre activité.

La ville d'Austin met à disposition des données sur plus de 649 000 voyages à vélo entre 2013 et 2017.

Contenu :
---------

-   Se connecter à Vantage
-   Explorer les données
-   Créer et explorer des données temporelles, géospatiales et chronologiques
-   Informations
-   Nettoyer

1. Se connecter à Vantage
=========================

Ouvrez l'éditeur pour poursuivre ce cas d'utilisation. [LANCER L'ÉDITEUR](#data=%7B%22navigateTo%22:%22editor%22%7D)

1.1 Obtention des données pour cette démo
-----------------------------------------

Sélectionnez **Charger les actifs** pour créer les tables et charger les données requises dans votre compte (instance de base de données Teradata) pour ce cas d'utilisation.

[Charger les actifs](#data=%7B%22id%22:%22New%22%7D)

Nous avons fourni des données pour cette démo sur le stockage cloud. Vous pouvez exécuter la démo en utilisant des tables externes pour accéder aux données sans aucun stockage dans votre environnement ou télécharger les données vers le stockage local, ce qui peut permettre une exécution plus rapide. Néanmoins, il peut y avoir des considérations de stockage disponible. Deux instructions se trouvent dans la cellule suivante, et l'une d'elles est commentée. Vous pouvez basculer entre les modes en modifiant la chaîne de commentaire.

    -- call get_data('DEMO_AustinBikeShare_cloud');           -- Takes 20 seconds
    call get_data('DEMO_AustinBikeShare_local');           -- Takes 50 seconds

Étape facultative : si vous souhaitez voir l'état des bases de données ou des tables créées et l'espace utilisé.

    call space_report();

2. Explorer les données
=======================

Pour commencer, examinons les tables de notre base de données TRNG\_AustinBike.

```sql
SELECT 
    DatabaseName,
    TableName
FROM
    DBC.Tables
WHERE
    DatabaseName = 'DEMO_AustinBikeShare'
```

Nous constatons que notre base de données contient trois tables. La table Voyages contient des données sur les voyages effectués à l'aide des vélos, la table Stations contient les emplacements des stations de vélos et la table Météo contient des données météorologiques.

La requête ci-dessous indique le nombre de lignes dans chacune des tables de la base de données.

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

2.1 Examiner la table Voyages
-----------------------------

Regardons les exemples de données dans la table Voyages.

```sql
SELECT
    *
FROM
    DEMO_AustinBikeShare.trips
SAMPLE 10;
```

Quel type d'abonnés fait le plus de balades ?

```sql
select top 10 count(trip_id) as ride_count, subscriber_type from DEMO_AustinBikeShare.trips group by subscriber_type order by 1 desc;
```

D'après le résultat ci-dessus, nous pouvons dire que **Randonnée** balades coûtent 250 % de plus que le deuxième type d'abonnement le plus populaire.

De quelle station partent le plus grand nombre de voyages ?

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

Nous constatons que **Riverside @ S. Lamar** présente le plus grand nombre de voyages provenant d'ici.

Voyons le nombre moyen de voyages au départ d'une station.

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

Nous constatons que la station principale\*\* Riverside @ S. Lamar\*\* présente 4 fois plus de voyages que la moyenne.

Examinons maintenant la tendance d'utilisation du vélo au fil du temps.

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

Dans le graphique ci-dessus, nous observons quelques éléments :

-   Pendant deux mois, les données sont pratiquement manquantes
-   Le pic d'utilisation mensuel peut atteindre 30 000 voyages
-   Mars et octobre sont les premier et deuxième mois les plus chargés sur les 4 dernières années.

Cela peut-il être lié à la météo ? La météo en mars et en octobre est-elle propice à la pratique du vélo ? Voyons cela dans la section suivante.

2.2 Examiner la table Météo
---------------------------

```sql
SELECT * FROM DEMO_AustinBikeShare.weather SAMPLE 10;
```

Les données de température sont indiquées toutes les heures (les minutes et les secondes sont toujours à zéro). Les colonnes de température sont en Kelvin, une valeur que peu de gens utilisent pour décider si la météo permet de faire du vélo. Nous allons donc créer une vue sur la table Météo pour convertir la température en degrés Fahrenheit. Nous ferons également la moyenne de la température pour la journée.

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

Si nous traçons les données, nous constatons qu'il manque certaines données, mais nous obtenons une idée des plages de températures typiques. Si nous examinons les heures de précipitations chaque mois, nous observons certaines tendances qui pourraient également avoir une incidence sur le nombre de voyages.

%chart dt, avetemp, width = 800, title = « Température moyenne par mois » Ici, nous observons que pendant presque tous les mois de mars et d'octobre, la température est d'environ 70 degrés Fahrenheit. Cette température est favorable pour faire du vélo, car il ne fait ni trop froid ni trop chaud.

%chart dt, Precip\_hours, width = 800, title = « Heures de précipitations moyennes par mois » D'après les deux graphiques ci-dessus, mars et octobre présentent des conditions favorables pour faire du vélo, ce qui se reflète dans l'augmentation des balades à vélo.

2.3 Données géospatiales
------------------------

Les colonnes géospatiales comportent un type et une ou plusieurs paires de Latitude et de Longitude. Nous avons inclus les colonnes Latitude et Longitude dans la table afin que vous puissiez voir comment une fonctionnalité géospatiale simple (un POINT) est représentée. Pour connaître plus de types de données géospatiales pris en charge par Teradata, cliquez ici.

```sql
SELECT * FROM DEMO_AustinBikeShare.stations SAMPLE 5;
```

Il existe de nombreuses fonctions géospatiales, mais nous pouvons en expliquer les bases en trouvant la distance entre le bureau principal (station\_id = 1001) et d'autres stations.

Pour obtenir plus de fonctions géospatiales prises en charge par Teradata, cliquez ici.

```sql
SELECT
    TOP 10 station.station_id, station.name, 
    ROUND(office.location.ST_SphericalDistance(station.location), 0) Distance_Meters
FROM DEMO_AustinBikeShare.stations station, DEMO_AustinBikeShare.stations office
WHERE office.station_id = 1001
ORDER BY 1;
```

3. Créer et explorer des données temporelles, géospatiales et chronologiques
============================================================================

3.1 Créer une table temporelle avec des données météorologiques
---------------------------------------------------------------

Les tables temporelles stockent et conservent des informations concernant le temps. À l'aide de tables temporelles, Vantage peut traiter des instructions et des requêtes qui incluent un raisonnement basé sur le temps. Les tables temporelles comportent une ou deux colonnes spéciales qui stockent des informations temporelles :

Une colonne de temps de transaction enregistre et conserve la période pendant laquelle Vantage a eu connaissance des informations de la ligne. Vantage saisit et conserve automatiquement les données de la colonne de temps de transaction et suit par conséquent l'historique de ces informations. Une colonne de temps de validité modélise le monde réel et stocke des informations, telles que la durée de validité d'une police d'assurance ou d'une garantie de produit, la durée d'emploi d'un employé ou d'autres informations importantes à suivre et à manipuler en fonction du temps. Lorsque vous ajoutez une nouvelle ligne à ce type de table, vous utilisez la colonne de temps de validité pour spécifier la période pendant laquelle les informations de la ligne sont valides. Il s'agit de la période de validité (PV) des informations de la ligne.

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

Ici, nous convertissons temp, temp\_min et temp\_max de Kelvin en degrés Fahrenheit tout en insérant les données dans la table weather\_temporal.

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

Nous pouvons désormais répondre plus rapidement et plus efficacement aux requêtes de raisonnement basées sur le temps grâce aux tables temporelles. Par exemple, la météo était-elle favorable à la pratique du vélo en mars et en octobre 2016 ?

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

Les graphiques ci-dessus suggèrent que les mois de mars et d'octobre 2016 ont connu plus de jours favorables à la pratique du vélo (ciel clair, nuageux, brumeux), ce qui explique l'augmentation du nombre de balades à vélo.

3.2 Créer une vue pour tous les voyages avec les données des stations de départ ou d'arrivée et une SÉQUENCE GÉOGRAPHIQUE avec latitude/longitude/heure de début/fin
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

Le code ci-dessous définit une vue qui améliore les données de voyage avec un champ Séquence géographique contenant l'emplacement et l'heure des points de départ et d'arrivée du voyage.

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

3.3 Créer une table chronologique des voyages pour accélérer l'analyse liée au temps
------------------------------------------------------------------------------------

Vantage prend en charge les tables avec un indice chronologique principal (PTI), qui permet de stocker et de rechercher rapidement les données qui parviennent en fonction du temps. Cet indice chronologique répartit les données sur les unités de parallélisme. Il permet néanmoins au système d'optimisation de créer des plans qui sont liés directement à l'unité de parallélisme dans laquelle les données sont stockées en fonction de la contrainte temporelle.

Dans ce cas, nous allons déclarer l'indice comme ayant une granularité horaire avec une heure de référence antérieure à toute date de données dont nous disposons. Sur la base de la déclaration de l'indice principal, la base de données crée automatiquement la première colonne avec le nom TD\_TIMECODE. Lorsque nous insérons des données, nous utilisons la colonne start\_time comme valeur.

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

Nous remplissons désormais la table locale. L'extraction des données du stockage cloud peut prendre une minute.

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

3.4 Augmenter les données de voyage avec des informations météorologiques et extraire des informations géospatiales
-------------------------------------------------------------------------------------------------------------------

Enfin, nous regroupons les données avec les informations de voyage de la séquence géographique avec les données météorologiques disponibles, où la période du rapport météo contient l'heure de début du voyage (TD\_TIMECODE).

Pour obtenir plus de fonctions géospatiales prises en charge par Teradata, cliquez ici.

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

4. Informations
===============

4.1 Distance moyenne parcourue par rapport aux stations de départ
-----------------------------------------------------------------

```sql
SELECT
    start_station_name, AVG(total_distance), COUNT(trip_id)
FROM trips_and_weather
GROUP BY start_station_name
ORDER BY 2 DESC;
```

La visualisation ci-dessus suggère que le bureau principal est celui dont la distance parcourue moyenne par les gens est la plus élevée. Même si seulement dix voyages partent de la station principale, c'est toujours celui où la distance moyenne parcourue est la plus élevée. Ces dix voyages sont très longs.

4.2 Effet de la météo sur la distance parcourue
-----------------------------------------------

```sql
SELECT
    TOP 10 SUM(total_distance) AS distance_km, subscriber_type, weather_main
FROM trips_and_weather
GROUP BY subscriber_type, weather_main
ORDER BY 1 DESC;
```

En regardant les résultats ci-dessus, les abonnés randonneurs, local365 et local30 ont parcouru une plus grande distance lorsque le temps était clair ou nuageux.

4.3 Durée moyenne du voyage en fonction du type d'abonné et du type de voyage
-----------------------------------------------------------------------------

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

En regardant les résultats ci-dessus, les voyages aller-retour sont plus longs que les voyages point à point pour les explorateurs, les randonneurs et les membres annuels.

4.4 Le vélo nécessite-t-il un entretien ?
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

En regardant les résultats ci-dessus, 50 vélos nécessitent un entretien selon notre hypothèse selon laquelle nous devrions effectuer des réparations de vélo tous les 70 km.

5. Nettoyer
===========

5.1 Tables de travail
---------------------

Nettoyez les tables de travail pour éviter les erreurs la prochaine fois. Cette section supprime toutes les tables créées pendant la démonstration.

```sql
DROP TABLE weather_temporal;
DROP TABLE trips_geo_pti;
DROP TABLE trips_and_weather;
DROP VIEW trips_geo;
```

5.2 Bases de données et tables
------------------------------

Le code suivant nettoie les tables et les bases de données créées ci-dessus.

```sql
call remove_data('DEMO_AustinBikeShare')
```

Liens :
=======

Des informations sur le type de données Géospatial peuvent être trouvées ici. Des informations sur le type de données Temporel sont disponibles ici
