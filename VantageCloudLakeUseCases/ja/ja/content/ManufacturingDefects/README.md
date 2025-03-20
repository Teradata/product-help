製造上の欠陥の分析
------------------

### 始める前に

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

### はじめに

ご自身が大手自動車メーカーのアナリストだとします。Teradata VantageCloud Lakeで通常の財務報告書に目を通しているとき、保証修理の増加という重大な事業上の問題が見つかりました。

![png](costs.png)

この問題は、電気自動車(EV)製品に組み込まれる最も高価で重要なコンポーネントの1つであるバッテリー パック交換によって発生しているようです。VantageCloud Lakeの独自の機能を使用して、製造プロセス中にキャプチャされた構造化データと半構造化データの両方を分析し、根本原因を特定して最終的に問題に対処することができます。

### エクスペリエンス

「体験」セクションの実施所要時間は約15分です。

### セットアップ

**アセットをロード** を選択してテーブルを作成し、このユース ケースに必要なデータを自分のアカウント(Teradataデータベース インスタンス)にロードします。[アセットをロード](#data=%7B%22id%22:%22EVCarBattery%22%7D)

### ウォークスルー

------------------------------------------------------------------------

#### ステップ1:根本原因の絞り込み

バッテリーを交換したすべての車両のレポートを実行し、バッテリーと車両の情報をサービス ディーラーと組み合わせます。この例では、すべてのデータがデータベースにありますが、現実の世界では、異なるデータセットを組み合わせることが効果的な分析の鍵となります。VantageCloud Lakeを使用すると、ユーザーはさまざまなサードパーティ システム、データレイク、オブジェクト ストアからのデータを大規模に組み合わせて、迅速かつ詳細な分析を行うことができます。

``` sourceCode
SELECT d.company, count(*)
FROM ev_dealers d, ev_badbatts bb,
ev_vehicles v
WHERE bb.vin = v.vin
AND v.dealer_id = d.id
GROUP BY d.company order by 2 desc
```

次に、車両のモデルに基づいてデータをグループ化します。当社では、製品ライン全体のさまざまなモデルで同じバッテリー部品セットを使用しています。

``` sourceCode
SELECT v.model, count(*)
FROM ev_vehicles v, ev_badbatts bb
WHERE bb.vin = v.vin
GROUP BY v.model order by 2 desc
```

ここには目立った問題はないようです。

次に自動車が製造された組立工場ごとにグループ化します。

``` sourceCode
SELECT mfg.company, count(*)
FROM ev_mfg_plants mfg, ev_badbatts bb,
ev_vehicles v
WHERE bb.vin = v.vin
AND v.mfg_plant_id = mfg.id
GROUP BY mfg.company order by 2 desc
```

同じ組立工場から出荷される欠陥車が非常に多く見られます。

次に不良バッテリーを搭載した車に搭載されているバッテリー セルを調べます。部品番号を使用してデータを集約します。

``` sourceCode
SELECT DISTINCT bom.part_no, p.description, count(*)
FROM ev_bom bom, ev_badbatts bb, ev_parts p
WHERE bb.vin = bom.vin
AND bom.part_no = p.part_no
AND p.description LIKE 'Battery Cell%'
GROUP BY bom.part_no, p.description
```

このクエリーを実行した後、part\_no 20rd0に問題があるようです。

VantageCloud Lakeを使用すると、パフォーマンスとコストが最適化されたオブジェクト ストレージに膨大な量のデータを保存して分析できます。このデモでは、詳細な製造データを統合データウェアハウスに保存します。これらのバッテリー セルのロット番号に相関関係があるかどうかを確認します。

``` sourceCode
SELECT bom.part_no, bom.lot_no, p.description, count(*)
FROM ev_bom bom, ev_badbatts bb, ev_parts p
WHERE bb.vin = bom.vin
AND p.part_no = bom.part_no
AND p.description LIKE 'Battery Cell%'
GROUP BY bom.part_no, bom.lot_no, p.description
ORDER BY count(*) DESC
```

上記のクエリーは、part\_no 20rd0の根本的な問題を示しています。故障のほとんどはバッテリー ロット4012(ジャクソン工場に配送)によるもので、保証交換の原因となっている不良バッテリーが大量に含まれています。これらの分析情報は、VantageCloud Lakeに直接接続してインタラクティブで反復的な分析を可能にする、お気に入りのビジネス インテリジェンス(BI)ツールのダッシュボードでさらにわかりやすく表示されます。

![png](dashboard.png)

自社の最新型コネクテッドEV自動車からは、詳細なセンサー データも得られます。問題のバッテリー ロットの温度センサー データを見てみましょう。

![png](4102temps.png)

それを平均的なバッテリー ロットと比較します。

![png](avgtemps.png)

バッテリー パックのモデル/ロット番号によっては、バッテリー パック内で高温/過熱が発生することがはっきりとわかります。保証費用増加の根本的な原因はわかりましたが、車両が組み立てられテストされた時点までさかのぼって、問題をさらに深く掘り下げていきたいと思います。

#### ステップ2:他にもデータが必要 - 社内のデータレイクからテスト結果にアクセス

この分析をさらに進めて、不良バッテリーがお客様の車に搭載される前に、それを検出できる方法を理解したいと考えています。これにより、将来的に高額な保証修理サイクルやお客様の不満を回避することができます。

自動車が製造されると、車両を構成する部品とサブシステムの詳細なテスト レポートが保存されます。これらのレポートは膨大で、半構造化形式で、オブジェクト ストアに格納されたデータレイクに保存されます。

VantageCloud Lakeを使用することで、このデータをネイティブに取り込み分析に応用できます。

まず、外部オブジェクト ストアに認証するための承認オブジェクトを作成します。実際には、保護されたリソースにアクセスするために、空白部分を適切な資格情報またはIDおよびアクセス管理(IAM)ロールに置き換えます。ここでは、公開されているリソースにアクセスするための空白を作成します。

``` sourceCode
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

次に、 Amazon S3内のJSON形式のデータにアクセスするための外部テーブルを作成します。外部テーブルを使用すると、データベース内の通常のテーブルと同じようにリモート データにアクセスできます。

``` sourceCode
CREATE FOREIGN TABLE test_reports , FALLBACK ,
     EXTERNAL SECURITY MyAuth
(
    Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
    payload JSON(16776192) INLINE LENGTH 64000 CHARACTER SET LATIN)
USING (
    Location ('/s3/s3.amazonaws.com/trial-datasets/EVCarBattery/')
), NO PRIMARY INDEX;
```

3番目に、10行のサンプルをチェックしてデータを検証します。

``` sourceCode
SELECT TOP 10 *
FROM test_reports
```

外部テーブルの上にユーザーフレンドリーなビューを配置すると、JSON処理関数を使用して、データをより簡単な形式で公開できるようになります。これらの関数は、大規模な半構造化データ処理で非常によく使用されます。

``` sourceCode
REPLACE VIEW test_reports_v AS
(SELECT vin, part_no, lot_no, CAST(test_report AS JSON) test_report
FROM TD_JSONSHRED(
    ON (
                SELECT payload.vin as vin, payload
                FROM test_reports)
            USING
            ROWEXPR('parts')
            COLEXPR('part_no', 'lot_no', 'test_report') 
            RETURNTYPES('VARCHAR(17)', 'VARCHAR(1000)', 'VARCHAR(10000)')
        ) AS d1 (vin, part_no, lot_no, test_report)
    )
```

次に、ビューをクエリーして、処理されたデータのサンプルを確認します。

``` sourceCode
SELECT TOP 10 *
FROM test_reports_v
```

#### ステップ3:VantageでJSON形式の製造試験データにネイティブにアクセスし結合

それは良さそうです。では、テストレポートを確認しましょう。テスト時には、さまざまな部分で異なるデータが報告されます。最も簡単な部分のテスト結果は次のようになります。

``` sourceCode
SELECT TOP 1 test_report
FROM test_reports_v
WHERE part_no = '11400zn'
```

対照的に、バッテリーのテスト レポートにはバッテリーの組み立て後車両に搭載される前の性能に関する詳細なデータが含まれています。

``` sourceCode
SELECT TOP 1 test_report
FROM test_reports_v
WHERE part_no = '20rdS0'
```

バッテリーに関して、定格容量と測定容量を部品番号やロット番号と共に比較したいと考えています。必要なテスト結果にアクセスするために、簡単なドット表記を使用してJSONデータを簡単に掘り下げることができます。

``` sourceCode
SELECT TOP 10 tr.part_no, p.description, tr.lot_no, 
tr.test_report."Rated Capacity" AS rated_capacity,
tr.test_report."Static Capacity Test"."Measured Average Capacity" AS measured_capacity
FROM ev_parts p, test_reports_v tr
WHERE  p.part_no = tr.part_no
AND p.description LIKE 'Battery Cell%'
```

これをBIツールで可視化すると、これらのバッテリーパックは仕様内に収まっていますが、他のバッテリーロットに比べて範囲がはるかに低いことがわかります。受け入れ基準を厳しくし、このようなプロアクティブな分析を行うことで、車が完成して顧客に納品される前に品質問題の可能性を特定できます。これらの取り組みにより、製品の品質が向上し、再発を防ぐことができます。

![png](batterylotcapacity.png)

VantageCloud Lakeを使用して統合データとデータレイクの両方を分析することで、事実上あらゆるビジネス上の問題を迅速かつ簡単に突き止めることができます。

#### ステップ4: クリーンアップ

独自のデータベース スキーマで作成したオブジェクトを削除します。

``` sourceCode
DROP TABLE test_reports;
```

``` sourceCode
DROP VIEW test_reports_v;
```

データセット
------------

------------------------------------------------------------------------

**bom** - BOM (部品表) - 個々の車両を構成するあらゆる主要パーツが含まれています。

-   `id`: 固有の識別子
-   `vin`: 車両識別番号
-   `part_no`: 部品番号
-   `vendor_id`: 部品を作成したベンダー(未使用)
-   `lot_no`: ベンダーによるロット番号
-   `quantity`: この部品が車両に使われている数

**dealers** - 車両の販売流通業者:

-   `id`: 固有の識別子
-   `Company`: 社名
-   `StreetAddress`: ストリート アドレス
-   `City`: 都市
-   `State`: 州
-   `ZipCode`: 郵便番号
-   `Country`: 国
-   `EmailAddress`: メインの電子メール アドレス
-   `TelephoneNumber`: 電話番号
-   `DomainName`:企業ウェブサイトのURL
-   `Latitude`: 緯度(位置)
-   `Longitude`: 経度(位置)

**mfg\_plants** - 製造工場:

-   `id`: 固有の識別子
-   `Company`: 工場名
-   `StreetAddress`: ストリート アドレス
-   `City`: 都市
-   `State`: 州
-   `ZipCode`: 郵便番号
-   `Country`: 国
-   `EmailAddress`: メインの電子メール アドレス
-   `TelephoneNumber`: 電話番号
-   `DomainName`:工場ウェブサイトのURL
-   `Latitude`: 緯度(位置)
-   `Longitude`: 経度(位置)

**parts** - 全車両向け部品のマスター リスト:

-   `part_no`: 固有の部品番号
-   `description`: 部品の説明

**vehicles** - 製造済み製造中の車両:

-   `vin`: 固有の識別子
-   `yr`: 年式
-   `model`: 車両型式
-   `customer_id`: 顧客/購入者
-   `dealer_id`: 車両を販売/納入したディーラー
-   `mfg_plant_id`: 車両を組み立てた工場
