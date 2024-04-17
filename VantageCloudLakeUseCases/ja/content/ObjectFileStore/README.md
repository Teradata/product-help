### VantageCloud Lake Editionのオブジェクト ファイル システムへのデータの保存

### 始める前に

エディタを開いてこのユース ケースを進めます。
[エディタを起動する](#data={"navigateTo":"editor"})

### はじめに

VantageCloud Lake Editionのオブジェクト ファイル システム (OFS) にデータを保存する方法の概要は次のとおりです。

### セットアップ

S3バケットにデータを含む外部テーブルを作成します。

```sql
REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
CREATE FOREIGN TABLE foreign_csvdata
,EXTERNAL SECURITY DefaultAuth
USING (location('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'));
```

外部テーブルのデータを確認します。

```sql
SELECT * FROM foreign_csvdata;
```

### シナリオ 1

S3バケットにデータを含む既存の外部テーブルがあり、そのデータを新しいOFSテーブルにロードしたい場合は、次のステートメントを使用できます。

```sql
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata )
WITH DATA;
```

新しいOFSテーブルのデータを確認します。

```sql
SELECT * FROM ofs_csvdata;
```

OFSテーブルを削除します。

```sql
DROP TABLE ofs_csvdata;
```

### シナリオ 2

既存のLakeファイル システムOFSテーブルがあり、そこに別のテーブルからデータをロードしたい場合は、次のステートメントを使用できます。

新しいOFSテーブルを作成します。

```sql
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

```sql
INSERT INTO ofs_csvdata SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata;
```

OFSテーブルのデータを確認します。

```sql
SELECT * FROM ofs_csvdata;
```

テーブルを削除します。

```sql
DROP TABLE ofs_csvdata;
DROP TABLE foreign_csvdata;
```

### シナリオ 3

オブジェクト ストアから新しいOFSテーブルに初めてデータをロードする場合は、次のステートメントを使用できます。

このオプションを使用するには、TD_SYSFNLIB.READ_NOSでEXECUTE権限が必要になります。これは以下の文によって付与できます。データベース管理者の協力を得てこの権限を取得してください。

```sql
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <username>;
```

```sql
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

```sql
SELECT * FROM ofs_csvdata;
```

テーブルを削除します。

```sql
DROP TABLE ofs_csvdata;
```
