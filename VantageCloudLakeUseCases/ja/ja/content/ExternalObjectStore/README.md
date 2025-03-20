外部オブジェクトストアの操作: データの読み取りと書き込み
--------------------------------------------------------

### 始める前に

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

### はじめに

このセクションでは、ユーザーがオープン オブジェクト ストアと対話する方法を説明します。Teradata VantageCloud Lakeは、これらのスケーラブルで低コストのデータ ストアへのデータの読み取りと書き込みの両方にネイティブ機能を提供するため、ユーザーはデータレイクに保存されている膨大な量のデータと簡単に統合できるほか、アーカイブ データやその他のデータをこれらのプラットフォームにオフロードできます。

評価の目的で、Teradataはオープン オブジェクト ストアの場所にデータを提供しています。実際の使用では、ユーザーはオブジェクト ストレージへのログイン資格情報またはその他のロール-ベースのアクセスを提供する必要があります。独自のオブジェクト ストアを使用してデータをクエリーする場合は、SQLコードで次の部分を置き換えます。

-   **LOCATION** - オブジェクト ストアの場所に置き換えます。場所は /s3/ (Amazon)、/az/ (Azure)、または /gs/ (Google) で始まる必要があります。
-   **USER** または **ACCESS\_ID** - オブジェクト ストアのユーザー名を追加します。
-   **PASSWORD** または **ACCESS\_KEY** - オブジェクト ストアにユーザーのパスワードを追加します。
-   **SESSION\_TOKEN** - AWS Security Token Serviceを使用してアクセス認証情報を提供する場合は、オプションのセッション トークンを追加することもできます。
-   必要に応じてEXTERNAL SECURITY句のコメントを解除します。

オブジェクト ストア内の独自のデータにアクセスするためにSQLを変更する場合は、VantageCloud Lake環境からのアクセスを許可するように構成されていることを確認してください。CREATE AUTHORIZATIONステートメントのUSER要素とPASSWORD要素、またはREAD\_NOSステートメントで使用されるAUTHORIZATION要素のJSON文字列引数に適切な資格情報を指定します。

これらのユースケースを実行するには、外部オブジェクト ストアの読み取りと書き込みに使用されるSQL関数に対する特定の権限がユーザーに必要です。管理者権限を持つデータベース ユーザーとして次のステートメントを実行するか、データベース管理者に実行を依頼してください。

``` sourceCode
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <USERNAME>;
GRANT EXECUTE FUNCTION ON TD_SYSFNLIB.WRITE_NOS TO <USERNAME>; 
```

### オブジェクト ストレージへのアクセス

オブジェクト ストアからデータを読み込むには2つの方法があります。

#### READ\_NOS

READ\_NOSテーブル演算子は、次の操作を実行できる関数です。 \* オブジェクト ストアに配置されているデータを使用して、Parquet、CSV、JSON形式のデータに対してアドホック クエリーを実行する \* オブジェクト ストアの構造(レイアウト)を調べる \* フォーマットされたデータのスキーマを調べる

``` sourceCode
--This SQL statement will query ten rows of data from the s3 bucket 
--defined in the LOCATION element 
SELECT TOP 10 * FROM ( 
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
  ) AS D; 

--By adding a RETURNTYPE element, and passing either 
-- ‘NOSREAD_KEYS' or ‘NOSREAD_SCHEMA’ arguments 
--users can investigate the objects and structure of the data 
SELECT TOP 10 * FROM (
    LOCATION = '/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
    RETURNTYPE = 'NOSREAD_KEYS' 
  ) AS D; 

SELECT TOP 10 * FROM ( 
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
    RETURNTYPE = 'NOSREAD_SCHEMA'
  ) AS D; 
```

### 独自のデータにアクセスする場合

認証を必要とする外部オブジェクト ストアにアクセスするには、承認オブジェクトを作成します。このオブジェクトには、データベースがデータの読み取り(および/または書き込み)に必要な資格情報(ユーザー名、パスワード、セッション トークン、ID およびアクセス管理(IAM)ロールなど) が含まれます。次のステートメントを使用して、外部オブジェクト ストアへの資格情報を含む承認オブジェクトを作成できます。または、資格情報をJSON形式の文字列としてクエリーのAUTHORIZATION要素に渡すこともできます。

``` sourceCode
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

### Amazon S3に保存されているデータにアクセスするための認証の使用

``` sourceCode
SELECT TOP 2 * FROM ( 
LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
AUTHORIZATION='{"ACCESS_ID":"","ACCESS_KEY":""}' 
--AUTHORIZATION='{"access_id":"ACCESS_KEY_ID","access_key":"SECRET_ACCESS_KEY"}'  --[optional AUTHORIZATION using direct credentials] 
--RETURNTYPE='NOSREAD_KEY'  --[optional if wanting to list the layout of the object store] 
--RETURNTYPE='NOSREAD_SCHEMA'  --[optional if wanting to display the schema of the data files]  
) AS D; 
```

#### 外部テーブル

外部テーブルにより、VantageCloud Lakeは、Amazon S3、Microsoft Azure Blob Storage、Google Cloud Storage内の半構造化データや非構造化データなどの外部オブジェクト ストレージ内のデータにアクセスできます。このデータのデータベース内統合により、データ サイエンティストやアナリストは、標準SQLを使用して、VantageCloud Lakeでこのデータを読み取り、処理できます。外部データをVantageCloud Lakeのリレーショナル データに結合し、組み込みのVantageCloud Lake分析機能と関数を使用して処理できます。

外部テーブルを通じて読み取られたデータは永続化されず、そのデータはそのクエリーでのみ使用できます。

データをデータベースにロードするには、CREATE TABLE AS … WITH DATA文でREAD\_NOSまたは外部テーブルから選択します。

### CREATE FOREIGN TABLEを使用してAmazon S3に格納されているデータにアクセスする

外部テーブルを作成する:

``` sourceCode
CREATE MULTISET FOREIGN TABLE sample_sensor ,FALLBACK,
     EXTERNAL SECURITY MyAuth
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

``` sourceCode
SELECT TOP 2 * FROM sample_sensor;
```

### Amazon S3に保存されているデータからVantageCloud Lakeにデータをインポートする

オブジェクト ストアからデータを永続化するには、次のようにCREATE TABLE ASステートメントを使用できます。CREATE CREATE TABLE AS内にREAD\_NOS SELECT文を埋め込み、すべての行をローカルテーブルに挿入するために必ずWITH DATAを含めます。

``` sourceCode
CREATE MULTISET TABLE sample_local_table AS (
  SELECT * FROM (
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
    AUTHORIZATION=MyAuth
  ) AS D
) WITH DATA;
```

オブジェクト ストアへのデータ書き込み
-------------------------------------

### はじめに

以下は、VantageCloud Lakeからオブジェクト ストアにデータをコピーする方法の概要です。以下のサンプル クエリーを実行するには、独自のbucketと認証情報(または承認オブジェクト)を指定する必要があります。

WRITE\_NOSクエリーは、ターゲット オブジェクト ストアに書き込まれたオブジェクトとそのメタデータのリストを返します。これらの結果は、ログ記録/追跡可能性やその他の管理ユース ケースに役立ちます。

#### WRITE\_NOS

WRITE\_NOS を使用すると、次のことが可能になります。 \* オブジェクト ストアにデータを直接コピー/書き込む \* オプションでデータを圧縮する \*ソース テーブルの1つ以上の列を、ターゲット オブジェクト ストアのパーティション属性として指定する。パーティション属性は、データの書き込み時に追加のオブジェクト キーを生成するために使用されます。これらのキーは、オブジェクトを読み取る他のシステムで効率的なデータ編成とフィルタリングに使用できます。 \* コピー プロセス中に作成されたすべてのオブジェクトを含むマニフェスト ファイルを作成および更新する

以下の例を実行する前に、サンプル スクリプトの次のフィールドを置き換えます。 \* *YourBucketName* :書き込みアクセスがあるbucketまたは BLOBストアの名前に置き換える。 \* VantageCloud Lakeが適切な認証情報を渡すには、承認オブジェクトを使用するか、認証情報をJSON形式の引数として AUTHORIZATION要素に渡すことができる。 \* ストレージ認証情報を含む承認オブジェクトに置き換えるか、または: \* *AccessID* :bucketのアクセス キーから (オプション) - アクセス キーIDの例: AKIAIOSFODNN7EXAMPLE \* *AccessKey* :bucketのアクセス キーから (オプション) - シークレット アクセス キーの例: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### 例1

この例では、**sample\_sensor**テーブル(上記で作成)内のすべての行を取得するSELECT文の結果を使用し、それをLOCATION要素で指定されたアカウントまたはbucket内の *sample1*パーティションまたはコンテナに書き込みます。

``` sourceCode
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

この例では、同じ**sensor\_data**テーブルをソースとして使用し、今回は*sample2*パーティションの下でセンサーの日付年ごとにパーティション分割します。

``` sourceCode
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

### WRITE\_NOS結果を検証する

WRITE\_NOSユースケースの結果を検証するには、bucketユーザーの認証情報を使用して承認オブジェクトを作成し、上記のセクションの例で説明したようにParquetデータにアクセスするための外部テーブルを作成するか、上記のREAD\_NOS構文を使用して単純なSELECT文を実行します。

### クリーンアップ

独自のデータベース スキーマで作成したオブジェクトを削除します。

``` sourceCode
DROP AUTHORIZATION MyAuth;
```

``` sourceCode
DROP TABLE sample_sensor;
```

``` sourceCode
DROP TABLE sample_local_table;
```
