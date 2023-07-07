### VantageCloud Lake Editionのオブジェクト ファイル システムへのデータの保存

### 始める前に

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

### はじめに

VantageCloud Lake Editionのオブジェクト ファイル システム (OFS) にデータを保存する方法の概要は次のとおりです。

### セットアップ

S3バケットにデータを含む外部テーブルを作成します。アカウントのプロビジョニング時に認証オブジェクトretail\_sample\_data.DEMO\_AUTH\_NOSが作成されます。これは、S3バケットtd-usecases-data-storeへの読み取り専用アクセス権を持っています。

``` sourceCode
CREATE FOREIGN TABLE foreign_csvdata
,EXTERNAL SECURITY retail_sample_data.DEMO_AUTH_NOS
USING (location('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'));
```

外部テーブルのデータを確認します。

``` sourceCode
SELECT * FROM foreign_csvdata;
```

### シナリオ 1

S3バケットにデータを含む既存の外部テーブルがあり、そのデータを新しいOFSテーブルにロードしたい場合は、次のステートメントを使用できます。

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata )
WITH DATA;
```

新しいOFSテーブルのデータを確認します。

``` sourceCode
SELECT * FROM ofs_csvdata;
```

OFSテーブルを削除します。

``` sourceCode
DROP TABLE ofs_csvdata;
```

### シナリオ 2

既存のLakeファイル システムOFSテーブルがあり、そこに別のテーブルからデータをロードしたい場合は、次のステートメントを使用できます。

新しいOFSテーブルを作成します。

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata,
     STORAGE = TD_OFSSTORAGE
     (
      site_no INTEGER,
      datetime TIMESTAMP(0),
      Precipitation DECIMAL(3,2),
      GageHeight DECIMAL(3,2),
      Flow DECIMAL(3,2),
      GageHeight2 DECIMAL(3,2))
NO PRIMARY INDEX ;
```

OFSテーブルに外部テーブルからデータをロードします。

``` sourceCode
INSERT INTO ofs_csvdata SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata;
```

OFSテーブルのデータを確認します。

``` sourceCode
SELECT * FROM ofs_csvdata;
```

テーブルを削除します。

``` sourceCode
DROP TABLE ofs_csvdata;
DROP TABLE foreign_csvdata;
```

### シナリオ 3

オブジェクト ストアから新しいOFSテーブルに初めてデータをロードする場合は、次のステートメントを使用できます。

このオプションを使用するには、TD\_SYSFNLIB.READ\_NOSでEXECUTE権限が必要になります。これは以下の文によって付与できます。データベース管理者の協力を得てこの権限を取得してください。

``` sourceCode
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <username>;
```

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2
FROM (
LOCATION='/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'
AUTHORIZATION=retail_sample_data.DEMO_AUTH_NOS
) AS d
) WITH DATA;
```

新しいOFSテーブルのデータを確認する

``` sourceCode
SELECT * FROM ofs_csvdata;
```

テーブルを削除します。

``` sourceCode
DROP TABLE ofs_csvdata;
```
