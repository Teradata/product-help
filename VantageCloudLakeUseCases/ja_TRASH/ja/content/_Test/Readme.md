序章：
======

自転車シェアは人気のある代替交通手段になりつつあります。公共の交通サービスを提供するビジネスを運営していると仮定しましょう。さまざまな駅で交通サービスを利用できるようにする必要があります。公共が必要とする時に駅に設備があることを確保しなければなりません。また、天候が交通サービスの需要に大きな影響を与えることも知っています。このデモンストレーションでは、Vantage Geospatialと時系列機能を活用して、過去の旅行情報と天候情報を統合し、サービスを改善し、ビジネスを成長させる方法を示します。

Austin市は、2013年から2017年にかけての649,000回以上の自転車旅行に関するデータを公開しています。

コンテンツ：
------------

-   Vantageに接続する
-   データを探索する
-   テンポラル、地理空間、時間インデックスデータの作成と探索
-   インサイト
-   クリーンアップ

1. Vantageに接続する
====================

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

1.1 このデモのデータを取得する
------------------------------

**アセットをロード**を選択してテーブルを作成し、このユース ケースに必要なデータをアカウント(Teradataデータベース インスタンス)にロードします。

[アセットをロード](#data=%7B%22id%22:%22New%22%7D)

このデモ用のデータはクラウド ストレージ上に用意されています。外部テーブルを使用してデモを実行し、環境にストレージがなくてもデータにアクセスするか、データをローカル ストレージにダウンロードして実行速度を上げることができます。ただし、使用可能なストレージを考慮する必要があります。次のセルには2つのステートメントがあり、そのうちの1つはコメント アウトされています。コメント文字列を変更することで、モードを切り替えることができます。

    -- call get_data('DEMO_AustinBikeShare_cloud');           -- Takes 20 seconds
    call get_data('DEMO_AustinBikeShare_local');           -- Takes 50 seconds

オプションの手順 - 作成されたデータベース/テーブルのステータスと使用されているスペースを確認する場合。

    call space_report();

2. データを調査する
===================

ウォーミングアップとして、TRNG\_AustinBikeデータベースのテーブルを見てみましょう。

``` sourceCode
SELECT 
    DatabaseName,
    TableName
FROM
    DBC.Tables
WHERE
    DatabaseName = 'DEMO_AustinBikeShare'
```

データベースには3つのテーブルがあることがわかります。Tripsテーブルには自転車を使った旅行に関するデータが含まれ、stationsテーブルには自転車ステーションの場所が含まれ、weatherテーブルには天気に関する詳細が含まれます。

以下のクエリーは、データベース内の各テーブルの行数を表示します。

``` sourceCode
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

2.1 tripsテーブルを調べる
-------------------------

tripsテーブルのサンプル データを見てみましょう。

``` sourceCode
SELECT
    *
FROM
    DEMO_AustinBikeShare.trips
SAMPLE 10;
```

どのタイプの加入者が最も多くの利用していますか?

``` sourceCode
select top 10 count(trip_id) as ride_count, subscriber_type from DEMO_AustinBikeShare.trips group by subscriber_type order by 1 desc;
```

上記の結果から、**walk up**の利用は2番目に人気のあるサブスクリプション タイプよりも250%多いと言えます。

最も多くの利用者が出発する駅はどこですか?

``` sourceCode
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

**Riverside @ S. Lamar**から出発する旅行数が最も多いことがわかります。

駅ごとの平均利用回数を見てみましょう。

``` sourceCode
SELECT AVG(trips) FROM (
    SELECT
    start_station_name,
    COUNT(1) AS trips
    FROM
        DEMO_AustinBikeShare.trips
    GROUP BY 1
) AS t;
```

最上位の駅である\*\* Riverside @ S. Lamar\*\* では、平均よりも4倍多くの利用数があることがわかります。

それでは、自転車の利用パターンを時系列で見てみましょう。

``` sourceCode
SELECT
    TRUNC(start_time, 'Month') AS start_Month,
    COUNT(1) AS trips
FROM
    DEMO_AustinBikeShare.trips
GROUP BY 1
ORDER BY 1;
%chart start_Month, trips, title = "Trips by day", typex = t, width = 700
```

上のグラフでは、いくつかのことがわかります。

-   データがほとんど欠けている月が2つある
-   ピーク時には1か月で3万回も利用されている
-   4年間のデータを見ると、3月と10月は1番目と2番目に忙しい月。

これは天候に関連しているのでしょうか？3月と10月の天候は自転車に乗るのに適しているのでしょうか？次のセクションで見てみましょう。

2.2 天候表を調べる
------------------

``` sourceCode
SELECT * FROM DEMO_AustinBikeShare.weather SAMPLE 10;
```

温度データは毎時報告されます（分と秒は常にゼロです）。温度の列はケルビンで表示されますが、ケルビンを使って自転車に適した天候かどうかを判断する人はほとんどいません。したがって、温度を華氏に変換するために天候表にビューを作成します。また、1日の平均温度も計算します。

``` sourceCode
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

データをプロットすると、一部のデータが欠けていることがわかりますが、典型的な温度範囲の概念を得ることができます。各月の降水が発生する時間を調べると、利用数に影響を与える可能性のあるパターンが見えてきます。

%chart dt, avetemp, width = 800, title = “月別の平均温度” ここでは、ほぼすべての3月と10月の月において、温度が華氏70度前後であることが観察できます。これは、自転車に乗るのに適した温度であり、寒すぎず暑すぎもしません。

%chart dt, Precip\_hours, width = 800, title = “月別の平均降水時間” 上記の2つのチャートから、3月と10月は自転車に乗るのに適した条件が整っており、それが利用数の増加に反映されています。

2.3 地理空間データ
------------------

地理空間の列には、タイプと1組以上の緯度と経度のペアがあります。テーブルに緯度と経度の列を含めたので、シンプルな地理空間機能（ポイント）がどのように表現されるかを見ることができます。Teradataがサポートするその他の地理空間データ型については、こちらをクリックしてください。

``` sourceCode
SELECT * FROM DEMO_AustinBikeShare.stations SAMPLE 5;
```

多くの地理空間関数が存在しますが、基本を示すために、メインオフィス（station\_id = 1001）から他の駅までの距離を見つけることで説明できます。

Teradataがサポートするその他の地理空間機能については、ここをクリックしてください。

``` sourceCode
SELECT
    TOP 10 station.station_id, station.name, 
    ROUND(office.location.ST_SphericalDistance(station.location), 0) Distance_Meters
FROM DEMO_AustinBikeShare.stations station, DEMO_AustinBikeShare.stations office
WHERE office.station_id = 1001
ORDER BY 1;
```

3. テンポラル、地理空間、時間インデックス データを作成と探索する
================================================================

3.1 気象データを含む一時テーブルを作成する
------------------------------------------

テンポラル テーブルは、時間に関する情報を保存および管理します。テンポラル テーブルを使用すると、Vantageは時間に基づく推論を含むステートメントやクエリを処理できます。テンポラル テーブルには、時間情報を保存する1つまたは2つの特別な列があります。

トランザクション時間列は、Vantageが行の情報を認識していた期間を記録および維持します。Vantageはトランザクション時間列データを自動的に入力および維持し、その情報の履歴を追跡します。有効時間列は現実世界をモデル化し、保険契約や製品保証が有効な期間、従業員の雇用期間、または時間を意識して追跡および操作することが重要なその他の情報を保存します。このタイプのテーブルに新しい行を追加する場合、有効時間列を使用して行情報が有効である期間を指定します。これは行の情報の有効期間（PV）です。

``` sourceCode
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

ここでは、weather\_temporalテーブルにデータを挿入しながら、temp、temp\_min、temp\_maxをケルビンから華氏に変換しています。

``` sourceCode
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

テンポラル テーブルを使用すると、時間ベースの推論クエリーに迅速かつ効率的に回答できるようになりました。たとえば、2016年の3月と10月の天候は自転車を乗るのに適していましたか?

``` sourceCode
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

上記のグラフは、2016年3月と10月は自転車に乗るのに適した日(晴れ、曇り、霧)が多かったことを示しており、これが自転車利用の増加につながったと説明できます。

3.2 出発/到着駅データと開始/終了の緯度/経度/時間を含むGEOSEQUENCEを使用して、すべての旅行のビューを作成する
-----------------------------------------------------------------------------------------------------------

以下のコードは、旅行の開始地点と終了地点の場所と時刻を含むGeosequenceフィールドを使用して旅行データを拡張するビューを定義します。

``` sourceCode
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

3.3 時間関連の分析を加速するために、旅行のタイムインデックステーブルを作成する
------------------------------------------------------------------------------

Vantageは、時間に基づいて到着するデータを保存および迅速に検索するために使用されるプライマリ タイム インデックス（PTI）を持つテーブルをサポートしています。この時間認識インデックスは、データを並列処理のユニット全体に分散しますが、オプティマイザが時間制約に基づいてデータが保存されている並列処理のユニットに直接アクセスする計画を立てることを可能にします。

この場合、インデックスを時間単位の粒度で宣言し、データの日付よりも前の基準時間を設定します。プライマリインデックスの宣言に基づいて、データベースはTD\_TIMECODEという名前の最初の列を自動的に作成します。データを挿入する際には、その値としてstart\_time列を使用します。

``` sourceCode
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

ここで、ローカル テーブルにデータを入力します。クラウド ストレージからデータを取得するには、1分ほどかかる場合があります。

``` sourceCode
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

3.4 旅行データに気象データを付加し、地理空間情報を抽出する
----------------------------------------------------------

最後に、利用可能な天候データを含む地理的シーケンス旅行情報とデータを統合します。天候報告期間には旅行の開始時間（TD\_TIMECODE）が含まれています。

Teradataがサポートするその他の地理空間機能については、ここをクリックしてください。

``` sourceCode
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

4. インサイト
=============

4.1 出発駅からの平均移動距離
----------------------------

``` sourceCode
SELECT
    start_station_name, AVG(total_distance), COUNT(trip_id)
FROM trips_and_weather
GROUP BY start_station_name
ORDER BY 2 DESC;
```

上記の可視化は、メイン オフィスの平均移動距離が最も長いことを示しています。メイン駅からの利用は10回のみですが、それでも平均移動距離が最も長くなっています。この10回の移動は非常に長いです。

4.2 天候が移動距離に与える影響
------------------------------

``` sourceCode
SELECT
    TOP 10 SUM(total_distance) AS distance_km, subscriber_type, weather_main
FROM trips_and_weather
GROUP BY subscriber_type, weather_main
ORDER BY 1 DESC;
```

上記の結果を見ると、walk-up、local365、local30の加入者は、天気が晴れまたは曇りのときに、より長い距離を移動したことがわかります。

4.3 加入者タイプと旅行タイプ別の平均旅行所要時間
------------------------------------------------

``` sourceCode
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

上記の結果を見ると、explorer、walk up、年間会員の場合、往復の旅行の方がポイント ツー ポイントの旅行よりも長いことがわかります。

4.4 自転車はメンテナンスが必要ですか?
-------------------------------------

``` sourceCode
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

上記の結果を見ると、70kmごとに自転車の修理を行うという想定によれば、50台の自転車のメンテナンスが必要であることがわかります。

5. クリーンアップする
=====================

5.1 作業テーブル
----------------

次回のエラーを防ぐために作業テーブルをクリーンアップします。このセクションでは、デモンストレーション中に作成されたすべてのテーブルを削除します。

``` sourceCode
DROP TABLE weather_temporal;
DROP TABLE trips_geo_pti;
DROP TABLE trips_and_weather;
DROP VIEW trips_geo;
```

5.2 データベースとテーブル
--------------------------

次のコードは、上記で作成したテーブルとデータベースをクリーンアップします。

``` sourceCode
call remove_data('DEMO_AustinBikeShare')
```

リンク:
=======

地理空間データ型に関する情報は、こちらでご覧いただけます。テンポラルデータ型に関する情報は、こちらでご覧いただけます。
