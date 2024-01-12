## 外部オブジェクト ストレージに対するデータのクエリー

### 始める前に

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

### はじめに

このセクションでは、VantageCloud Lakeからオブジェクト ストアにデータをコピーする方法を示します。クエリーの例を実行するには、自分のバケットの情報を入力する必要があります。 __sample_sensor__ テーブルは、Vantageシステムのテーブルから外部オブジェクト ストアへのデータのコピーをシミュレートします。これらの例は、独自のデータセットにアクセスするように編集できます。これらのデータセットの例にはログイン信頼証明は必要ありませんが、独自のデータセットにアクセスするにはログイン信頼証明を使用してください。

類似のSQLを使用して、独自のオブジェクト ストアにアクセスできます。以下を置き換えるだけです。
* __LOCATION__ - 独自のオブジェクト ストアの場所と置き換えます。その場所は、/s3/ (Amazon)、/az/ (Azure)、または/gs/ (Google)で始まる必要があります。
* __USER__ または __ACCESS_ID__ - 独自のオブジェクト ストアのユーザー名を加えます。
* __PASSWORD__ または __ACCESS_KEY__ - 独自のオブジェクト ストアのユーザーのパスワードを加えます。
* __SESSION_TOKEN__  - AWS Service Token Serviceを使用している場合はアクセス信頼証明を得られるようにオプションのセッション トークンを追加することもできます。
* 必要に応じてEXTERNAL SECURITY句でコメントを外します

自分のデータにアクセスするように編集する場合 - Vantage環境からアクセスできるように、オブジェクト ストアを設定する必要があります。USERおよびPASSWORD (CREATE AUTHORIZATIONコマンドで使用される)またはAUTHORIZATION単純構文(認証オブジェクトを使いたくない場合にREAD_NOSコマンドで使用される)に、信頼証明を入力します。

### セットアップ

このオプションを使用するには、TD_SYSFNLIB.READ_NOSでEXECUTE権限が必要になります。これは以下の文によって付与できます。データベース管理者の協力を得てこの権限を取得してください。

```sql
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <username>;
```

### オブジェクト ストレージへのアクセス

オブジェクト ストアからデータを読み込むには2つの方法があります。

#### READ_NOS

READ_NOSを使うと以下を実行できます。
* オブジェクト ストアにインプレースされたParquet、CSV、JSON形式のデータに対してアドホック クエリーを実行する 
* オブジェクト ストアの構造(レイアウト)を調べる 
* フォーマット済みデータのスキーマを調べる 
* データベースでの外部テーブル作成をバイパスする

#### 外部テーブル

CREATE TABLE権限を持つユーザーは、データベース内に外部テーブルを作成できます。この仮想テーブルをオブジェクトストアの場所にポイントし、SQLを使用してデータを業務に使いやすい形式に変換します。外部テーブルを使うと以下を実行できます。 
* 外部データをデータベースにロードする 
* 外部データをデータベース内に格納されているデータに結合する 
* データをフィルタリングする 
* ビューを使用して、データがユーザーに表示される方法を簡素化したり、セキュリティ アクセス制御を増強したりする

外部サーバー経由で読み込まれるデータは永続化されず、データはクエリーによってのみ表示できます。

データをデータベースにロードするには、CREATE TABLE AS … WITH DATA文でREAD_NOSまたは外部テーブルから選択します。

### 独自のデータにアクセスする場合

以下の文を使用して、信頼証明を外部オブジェクト ストアに含める認証オブジェクトを作成できます。

```sql
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

### READ_NOSを使用してAmazon S3に格納されているデータにアクセスする

```sql
SELECT TOP 2 * FROM (
LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
AUTHORIZATION='{"ACCESS_ID":"","ACCESS_KEY":""}'
--AUTHORIZATION='{"access_id":"ACCESS_KEY_ID","access_key":"SECRET_ACCESS_KEY"}'  --[optional AUTHORIZATION using direct credentials]
--RETURNTYPE='NOSREAD_KEY'  --[optional if wanting to list the layout of the object store]
--RETURNTYPE='NOSREAD_SCHEMA'  --[optional if wanting to display the schema of the data files] 
) AS D;
```

### CREATE FOREIGN TABLEを使用してAmazon S3に格納されているデータにアクセスする

外部テーブルを作成する:

```sql
CREATE MULTISET FOREIGN TABLE sample_sensor ,FALLBACK,
     EXTERNAL SECURITY MyAuth, MAP = TD_MAP1
    (
        sensedate DATE,
        sensetime TIME,
        epoch INTEGER,
        moteid INTEGER,
        temperature FLOAT,
        humidity FLOAT,
        light FLOAT,
        voltage FLOAT
    )
USING
    (
        LOCATION  ('/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/')
        MANIFEST  ('FALSE')
        ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
        STOREDAS  ('TEXTFILE')
        HEADER  ('FALSE')
        STRIP_EXTERIOR_SPACES  ('FALSE')
    )
NO PRIMARY INDEX ;
```

外部テーブルを使用していくつかのデータを表示します。

```sql
SELECT TOP 2 * FROM sample_sensor;
```

### Amazon S3に保存されているデータからVantageにデータをインポートする

オブジェクト ストアからのデータを永続化するには、次のようにCREATE TABLE AS文を使用できます。

```sql
CREATE MULTISET TABLE sample_local_table AS (
  SELECT * FROM (
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
    AUTHORIZATION=MyAuth
  ) AS D
) WITH DATA;
```

# オブジェクト ストアへのデータ書き込み

## はじめに

以下に、Vantageからオブジェクト ストアにデータをコピーする方法をまとめます。以下のクエリー例を実行するには、自分のバケットの情報を入力する必要があります。

## WRITE_NOS

WRITE_NOSを使用すると、次のことができます。
* オブジェクト ストアに直接、データをコピーする/書き込む 
* ユーザーがSnappy圧縮を指定している場合を除き、非圧縮のParquet形式のデータを変換する 
* ソース テーブルの1つ以上の列をターゲット オブジェクト ストアのパーティション属性として指定する 
* コピー プロセス時に作成されたすべてのオブジェクトを含めたマニフェスト ファイルを作成および更新する

以下の例を実行する前に、スクリプトの例で以下のフィールドを置き換えます。
* *YourBucketName*: 自分のバケットの名前と置き換える 
* *YourAuthObject*: ストレージの信頼証明を含む認証オブジェクト 
* [オプション] *AccessID*: バケットのアクセス キーから - アクセス キーIDの例:AKIAIOSFODNN7EXAMPLE 
* [オプション] *AccessKey*: 自分のバケットのアクセス キーから - シークレット アクセス キーの例: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### 例1

この例では、 __sample_sensor__ テーブルのすべての行を選択して、データセットをオブジェクト ストアの *sample1* パーティションにコピーします。

```sql
SELECT * FROM WRITE_NOS (
    ON ( SELECT * FROM sample_sensor )
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
        AUTHORIZATION (MyAuth)
--      AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        STOREDAS ('PARQUET')
) AS d;
```

### 例2

この例では、同じデータセットをコピーします。ここでは *sample2* パーティションの下にセンサー日付の年ごとにパーティション化します。

```sql
SELECT * FROM WRITE_NOS (
    ON ( SELECT
            sensedate,
            sensetime,
            epoch,
            moteid,
            temperature,
            humidity,
            light,
            voltage,
            year(sensedate) TheYear
        FROM sample_sensor )
    PARTITION BY TheYear ORDER BY TheYear
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample2/')
        AUTHORIZATION (MyAuth)
--      AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        NAMING ('DISCRETE')
        INCLUDE_ORDERING ('FALSE')
        STOREDAS ('PARQUET'))
 AS d;
```

### WRITE_NOS結果を検証する

WRITE_NOSユース ケースの結果は、前述のセクションの例で説明されたように、バケット ユーザー信頼証明を使用して認証オブジェクトを作成し次にParquetデータへのアクセス用に外部テーブルを作成することで検証できます。

### クリーンアップ

独自のデータベース スキーマで作成したオブジェクトを削除します。

```sql
DROP AUTHORIZATION MyAuth;
```

```sql
DROP TABLE sample_sensor;
```

```sql
DROP TABLE sample_local_table;
```
