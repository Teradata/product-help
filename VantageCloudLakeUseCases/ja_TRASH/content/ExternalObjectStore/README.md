外部オブジェクト ストアの操作:データの読み取りと書き込み
--------------------------------------------------------

### 始める前に

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

### はじめに

このセクションでは、ユーザーがオープン オブジェクト ストアとやり取りする方法を説明します。Teradata VantageCloud Lakeは、これらのスケーラブルで低コストのデータ ストアに対してデータの読み取りと書き込みの両方を行うネイティブ機能を提供しています。これにより、ユーザーはData Lakeに保存されている膨大な量のデータを容易に扱えるほか、アーカイブ データやその他のデータをこれらのプラットフォームにオフロードできます。

Teradataは、評価目的でオープン オブジェクト ストアの場所にデータを提供しています。実際の使用では、ユーザーがオブジェクト ストレージに対するログイン認証情報またはロールに基づいたその他のアクセスを提供する必要があります。独自のオブジェクト ストアを使用してデータをクエリーする場合は、SQLコードで以下を置き換えます。

-   **LOCATION** - オブジェクト ストアの場所に置き換えます。場所は、/s3/ (Amazonの場合)、/az/ (Azureの場合)、または /gs/ (Googleの場合) で始まる必要があります。
-   **USER** または **ACCESS\_ID** - オブジェクト ストアのユーザー名を追加します。
-   **PASSWORD** または **ACCESS\_KEY** - オブジェクト ストアのユーザーのパスワードを追加します。
-   **SESSION\_TOKEN** - AWS Security Token Serviceを使用してアクセス認証情報を提供する場合は、オプションでセッション トークンを追加することもできます。
-   必要に応じてEXTERNAL SECURITY句のコメントを解除する

SQLを変更してオブジェクト ストア内の独自のデータにアクセスできるようにする場合は、VantageCloud Lake環境からのアクセスを許可するように構成されていることを必ず確認してください。CREATE AUTHORIZATIONステートメントのUSER要素とPASSWORD要素、またはREAD\_NOSステートメントで使用されるAUTHORIZATION要素のJSON文字列引数に、適切な認証情報を指定します。

これらのユース ケースを実行するには、外部オブジェクト ストアの読み取りと書き込みに使用されるSQL関数に対し、ユーザーが特定の権限を持っている必要があります。次のステートメントは、管理者権限を持つデータベース ユーザーとして実行するか、データベース管理者に実行を依頼してください。

``` sourceCode
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <USERNAME>;
GRANT EXECUTE FUNCTION ON TD_SYSFNLIB.WRITE_NOS TO <USERNAME>; 
```

### オブジェクト ストレージへのアクセス

オブジェクト ストアからデータを読み込むには2つの方法があります。

#### READ\_NOS

READ\_NOSテーブル演算子は、次の操作を実行できる関数です: \* オブジェクト ストアにインプレースされたParquet、CSV、JSON形式のデータに対してアドホック クエリーを実行する \* オブジェクト ストアの構造 (レイアウト) を調べる \* フォーマットされたデータのスキーマを調べる

``` sourceCode
--このSQLステートメントは、S3バケットから10行のデータをクエリーします 
--LOCATION要素で定義されています 
SELECT トップ 10 * FROM ( 
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

### When accessing your own data

To access external object stores that require authentication, create an authorization object. This object will contain the credentials (username, password, session token, identity and access management (IAM) role, etc.) that the database needs to read (and/or write) data. The following statement can be used to create an authorization object to contain the credentials to your external object store. Alternatively, credentials can be passed as a JSON-formatted string to the AUTHORIZATION element of the query.

``` sourceCode
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

### Using an authorization to access data stored on Amazon S3

``` sourceCode
SELECT TOP 2 * FROM ( 
LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
AUTHORIZATION='{"ACCESS_ID":"","ACCESS_KEY":""}' 
--AUTHORIZATION='{"access_id":"ACCESS_KEY_ID","access_key":"SECRET_ACCESS_KEY"}'  --[optional AUTHORIZATION using direct credentials] 
--RETURNTYPE='NOSREAD_KEY'  --[optional if wanting to list the layout of the object store] 
--RETURNTYPE='NOSREAD_SCHEMA'  --[optional if wanting to display the schema of the data files]  
) AS D; 
```

#### Foreign Tables

Foreign tables enable VantageCloud Lake to access data in external object storage, such as semi-structured and unstructured data in Amazon S3, Microsoft Azure Blob Storage, and Google Cloud Storage. In-database integration of this data allows data scientists and analysts to read and process this data with VantageCloud Lake, using standard SQL. You can join external data to relational data in VantageCloud Lake, and process it using built-in VantageCloud Lake analytics and functions.

Data read through a foreign table is not persisted, and the data can only be used by that query.

Data can be loaded into the database by selecting from READ\_NOS or a foreign table in a CREATE TABLE AS … WITH DATA statement.

### Accessing data stored on Amazon S3 with CREATE FOREIGN TABLE

Create a foreign table:

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

View some data using the foreign table:

``` sourceCode
SELECT TOP 2 * FROM sample_sensor;
```

### Importing data into VantageCloud Lake from data stored on Amazon S3

To persist the data from an object store, we can use a CREATE TABLE AS statement as follows. Embed the READ\_NOS SELECT statement inside the CREATE TABLE AS, and be sure to include WITH DATA to insert all the rows into a local table:

``` sourceCode
CREATE MULTISET TABLE sample_local_table AS (
  SELECT * FROM (
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
    AUTHORIZATION=MyAuth
  ) AS D
) WITH DATA;
```

Writing Data to an Object Store
-------------------------------

### Introduction

The following is a summary of how to copy data from VantageCloud Lake to an object store. You must provide your own bucket and credentials (or authorization object) to execute the example queries below.

The WRITE\_NOS query returns the list of objects and their metadata written to the target object store. These results are useful for logging/traceability and other administrative and management use cases.

#### WRITE\_NOS

WRITE\_NOS allows you to: \* Copy / write data directly to an object store \* Optionally compress the data \* Specify one or more columns in the source table as partition attributes in the target object store. Partition attributes will be used to generate additional object keys when writing the data. These keys can be used for efficient data organization and filtering for other systems reading the objects. \* Create and update of manifest files with all objects created during the copy process

Before running the following examples, replace the following fields in the example scripts: \* *YourBucketName* : Replace with the name of your bucket or blob store where you have write access \* For VantageCloud Lake to pass the proper credentials, you can either use an authorization object or pass the credentials as a JSON-formatted argument to the AUTHORIZATION element. \* Replace with your authorization object containing your storage credentials, or: \* *AccessID* : from the Access Key for your bucket (optional) - Access key ID example: AKIAIOSFODNN7EXAMPLE \* *AccessKey* : from the Access Key for your bucket (optional) - Secret Access Key example: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### Example 1

This example will use the result of a SELECT statement that retrieves all rows in the **sample\_sensor** table (created above), and will write it to the *sample1* partition or container in the account or bucket specified in the LOCATION element:

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

### Example 2

This example uses the same **sensor\_data** table as a source, this time partitioning by the sensor date year under the *sample2* partition:

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

### Validate your WRITE\_NOS results

You can validate the results of your WRITE\_NOS use cases by creating an authorization object with your bucket user credentials and then creating a foreign table for accessing Parquet data as described in the examples in the above section, or by performing a simple SELECT statement using READ\_NOS syntax from above.

### Clean up

Drop the objects we created in our own database schema.

``` sourceCode
DROP AUTHORIZATION MyAuth;
```

``` sourceCode
DROP TABLE sample_sensor;
```

``` sourceCode
DROP TABLE sample_local_table;
```
