-   [クラウド オブジェクト ストレージのクエリ データ](#query-data-on-cloud-object-storage)
-   [クラウド オブジェクト ストレージへのデータ書き込み](#write-data-to-a-cloud-object-store)

クラウド オブジェクト ストレージのクエリ データ
-----------------------------------------------

### はじめに

次の例は、クラウド オブジェクト ストアに保存されているデータにアクセスする方法を示したものです。以下のサンプル クエリをコピーして変更することで、お客様固有のデータセットにアクセスできます。単純にするために、サンプル データセットはセットアップや認証情報が必要ないパブリック アクセス バケットを通じて提供されます。

SQL を使用してお客様固有のクラウド オブジェクト ストアにアクセスするには、次のものを置き換えます。\* **LOCATION** - オブジェクト ストアの場所に置き換えます。場所は、/s3/（Amazonの場合）または/az/（Azureの場合）で始まる必要があります。\* **AUTHORIZATION** - 空の **USER** および **PASSWORD** 認証情報を自分の **ACCESS\_KEY\_ID** および **SECRET\_ACCESS-KEY** と置き換えます。

**注**: AUTHORIZATION パラメータは、セキュリティを管理するのに IAM ロールとポリシーを使用していない場合にのみ必須です。

クラウド オブジェクト ストレージ データの読み取り
-------------------------------------------------

クラウド オブジェクト ストレージからの読み取りでは、Parquet、CSV、および JSON ファイル形式がサポートされています。READ\_NOS または外部テーブルを使ってクラウド オブジェクト ストレージからデータを読み取ることができます。

#### READ\_NOS

READ\_NOS では、データベースに変更を加える必要なく、次のことを行えます。\* クラウド オブジェクト ストアに保存されているデータに対してアドホック クエリを実行する。\* データ ファイルのスキーマを調査する。

#### 外部テーブル

CREATE TABLE 特権を持っている場合、データベース内にローカルのリレーショナル テーブルと同様に動作する外部テーブルを作成できます。外部テーブルを使用すると、次のことができます。 \* 外部データをデータベースにロードする \* 外部データとデータベースに保存されているデータを結合する \* データをフィルタリングする \* ビューを使用してデータの表示方法を簡素化する

Native Object Store を使用して読み取られたデータは永続化されません。

データは INSERT SELECT および CREATE TABLE AS … WITH DATA 文を使用してデータベースにロードできます。

### 認証オブジェクトを使用してセキュアド認証情報を設定する

認証オブジェクトを作成すると、Vantage 内のクラウド オブジェクト ストアに認証情報を安全に保存して参照できます。サンプル データセットは認証情報が必要ないパブリック アクセス バケットを通じて提供されていることに留意してください。

    CREATE AUTHORIZATION InvAuth
    USER ''
    PASSWORD '';

### Amazon S3 に保存されているデータを READ\_NOS を使用して読み取る

READ\_NOS を使用してクラウド オブジェクト ストアからデータを選択する:

    SELECT TOP 2 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    ) AS D;

### Amazon S3 に保存されているデータのスキーマを READ\_NOS を使用して調査する

READ\_NOS を使用してクラウド オブジェクト ストアからデータのスキーマのみを選択する:

    SELECT TOP 1 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    RETURNTYPE='NOSREAD_SCHEMA'
    ) AS d;

### Amazon S3 に保存されているデータを CREATE FOREIGN TABLE を使用して読み取る

外部テーブルを作成する:

    CREATE FOREIGN TABLE sample_data
    ,EXTERNAL SECURITY InvAuth
    USING ( LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/') );

外部テーブルを使用してデータを選択する:

    SELECT TOP 2 * FROM sample_data;

### Amazon S3 に保存されているデータから Vantage にデータをインポートする

クラウド オブジェクト ストアからのデータを永続化するには、CREATE TABLE AS 文を使用します。

    CREATE TABLE AS sample_data_local ( SELECT * FROM sample_data ) WITH DATA;

クラウド オブジェクト ストレージへのデータ書き込み
--------------------------------------------------

### はじめに

次の例は、Vantage からクラウド オブジェクト ストアにデータをコピーする方法を示したものです。サンプル クエリを実行するには、独自のバケットを用意する必要があります。

### WRITE\_NOS

WRITE\_NOS を使用すると、次のことができます。\* クラウド オブジェクト ストアに直接、データをコピーする/書き込む \* ユーザーが Snappy 圧縮を指定している場合を除き、非圧縮の Parquet 形式のデータを変換する \* ソース テーブルの 1 つ以上の列をターゲット クラウド オブジェクト ストアのパーティション属性として指定する \* コピー プロセス時に作成されたすべてのオブジェクトを含めたマニフェスト ファイルを作成および更新する

例を実行する前に、サンプル スクリプトの次のフィールドを置き換えてください。\* *YourBucketName* : バケット名に置き換えます。\* *AccessID* : バケットのアクセス キーから、アクセス キー ID に置き換えます。 - アクセス キー ID の例: AKIAIOSFODNN7EXAMPLE \* *AccessKey* : バケットのアクセス キーから、シークレット アクセス キーに置き換えます。 - シークレット アクセス キーの例: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

**ヒント**: *AccessID* 行および *AccessKey* 行の代わりに、認証オブジェクトを作成して、クラウド オブジェクト ストアの認証情報を安全に隠すことができます。

#### 例1

この例では、ローカルの sample\_data\_local のすべての行を選択して、そのデータセットをオブジェクト ストアの *sample1* パーティションにコピーします。

    SELECT * FROM WRITE_NOS (
        ON ( SELECT * FROM sample_data_local )
        USING
            LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
            AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
            --if using the authorization object, replace the line above with the line below minus the two dashes in front of the line:
            --AUTHORIZATION (authorization_object_name)        
            STOREDAS ('PARQUET')
    ) AS d;

#### 例2

この例は、*sample2* パーティションの下にセンサー日付の年ごとにパーティション化して、同じデータセットをコピーします。

    SELECT * FROM WRITE_NOS (
        ON ( SELECT
                sensdate
                ,senstime
                ,epoch
                ,moteid
                ,temperature
                ,humidity
                ,light
                ,voltage
                ,sensdatetime
                ,year(sensdate) TheYear
             FROM sample_data_local )
        PARTITION BY TheYear ORDER BY TheYear
        USING
            LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample2/')
            AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
            --if using the authorization object, replace the line above with the line below minus the two dashes in front of the line:
            --AUTHORIZATION (authorization_object_name)              
            NAMING ('DISCRETE')
            INCLUDE_ORDERING ('FALSE')
            STOREDAS ('PARQUET')
     AS d;

### WRITE\_NOS の結果の検証

READ\_NOSの例に示すように、Parquetデータを読み取ることで、WRITE\_NOSユース ケースの結果を検証できます。\#\#\#クリーンアップする

独自のデータベース スキーマで作成したオブジェクトを削除する:

    DROP AUTHORIZATION InvAuth;
    DROP TABLE sample_data;
    DROP TABLE sample_data_local;
