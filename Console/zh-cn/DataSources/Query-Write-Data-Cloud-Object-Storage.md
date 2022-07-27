本机对象库与云对象存储集成
==========================

-   [在云对象存储中查询数据](#query-data-on-cloud-object-storage)
-   [将数据写入云对象库](#write-data-to-a-cloud-object-store)

在云对象存储中查询数据
----------------------

### 简介

以下示例演示了如何访问云对象库中存储的数据。可以复制和修改下面的示例查询，以访问你自己的数据集。为简单起见，我们通过公共访问存储桶提供示例数据集，不需要设置或凭据。

要使用 SQL 访问你自己的云对象库，请执行以下替换：\* **LOCATION** - 替换为你的对象库的位置。位置必须以 /s3/ (Amazon) 或 /az/ (Azure) 开头。\* **AUTHORIZATION** - 将空 **USER** 和 **PASSWORD** 凭据替换为你的 **ACCESS\_KEY\_ID** 和 **SECRET\_ACCESS-KEY**。

**注意**：仅当不使用 IAM 角色和策略管理安全性时，才需要 AUTHORIZATION 参数。

读取云对象存储数据
------------------

从云对象存储读取时，支持 Parquet、CSV 和 JSON 文件格式。可以使用 READ\_NOS 或外表读取云对象存储中的数据。

#### READ\_NOS

READ\_NOS 允许在不更改数据库的情况下执行以下操作：\* 对云对象库中存储的数据执行即席查询 \* 检查数据文件的层次

#### 外表

使用 CREATE TABLE 权限可在数据库中创建外表，过程与使用本地关系表相似。通过使用外表，可以执行以下操作：\* 将外部数据加载到数据库 \* 将外部数据联接到数据库中存储的数据 \* 筛选数据 \* 使用视图简化向用户呈现数据的过程

使用本机对象库读取的数据不会持久保留。

可以使用 INSERT SELECT 和 CREATE TABLE AS … WITH DATA 语句将数据加载到数据库中。

### 使用授权对象设置安全凭据

创建授权对象后，可以安全地将凭据存储到 Vantage 中的云对象库并引用凭据。请注意，我们通过公共访问存储桶提供示例数据集，不需要凭据。

    CREATE AUTHORIZATION InvAuth
    USER ''
    PASSWORD '';

### 使用 READ\_NOS 读取 Amazon S3 上存储的数据

使用 READ\_NOS 从云对象库中选择数据：

    SELECT TOP 2 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    ) AS D;

### 使用 READ\_NOS 检查 Amazon S3 上存储的数据的层次

使用 READ\_NOS 仅从云对象库选择数据的层次：

    SELECT TOP 1 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    RETURNTYPE='NOSREAD_SCHEMA'
    ) AS d;

### 使用 CREATE FOREIGN TABLE 读取 Amazon S3 上存储的数据

创建外表：

    CREATE FOREIGN TABLE sample_data
    ,EXTERNAL SECURITY InvAuth
    USING ( LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/') );

使用外表选择数据：

    SELECT TOP 2 * FROM sample_data;

### 将 Amazon S3 上存储的数据导入到 Vantage

要持久保留云对象库中的数据，请使用 CREATE TABLE AS 语句：

    CREATE TABLE AS sample_data_local ( SELECT * FROM sample_data ) WITH DATA;

将数据写入云对象库
------------------

### 简介

以下示例演示如何将 Vantage 中的数据复制到云对象库。你必须提供自己的存储桶才能执行示例查询。

### WRITE\_NOS

使用 WRITE\_NOS 可执行以下操作：\* 将数据直接复制/写入到云对象库 \* 转换未压缩的 Parquet 格式的数据，除非用户指定了 Snappy 压缩 \* 将源表中的一个或多个列指定为目标云对象库中的分区属性 \* 创建和更新其中包含复制过程中创建的所有对象的清单文件

在运行示例前，替换示例脚本中的以下字段：\* *YourBucketName*：替换为你的存储桶的名称 \* *AccessID*：来自你的存储桶的访问密钥 - 访问密钥 ID 示例：AKIAIOSFODNN7EXAMPLE \* *AccessKey*：来自你的存储桶的访问密钥 - 密码访问密钥示例：wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

**提示**：作为 *AccessID* 和 *AccessKey* 行的替换项，可以创建授权对象来安全隐藏云对象库的凭据。

#### 示例 1

此示例选择本地 sample\_data\_local 中的所有行，将数据集复制到对象库的 *sample1* 分区：

    SELECT * FROM WRITE_NOS (
        ON ( SELECT * FROM sample_data_local )
        USING
            LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
            AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
            --if using the authorization object, replace the line above with the line below minus the two dashes in front of the line:
            --AUTHORIZATION (authorization_object_name)        
            STOREDAS ('PARQUET')
    ) AS d;

#### 示例 2

此示例通过按照 *sample2* 分区下的传感器日期年份进行分区来复制相同的数据集：

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

### 验证 WRITE\_NOS 结果

可以通过读取 Parquet 数据来验证 WRITE\_NOS 用例的结果，如此处的 READ\_NOS 示例所述：[使用 READ\_NOS 读取 Amazon S3 中存储的数据](#read-data-stored-on-amazon-s3-using-read_nos)

### 清理

删除在你自己的数据库层次中创建的对象：

    DROP AUTHORIZATION InvAuth;
    DROP TABLE sample_data;
    DROP TABLE sample_data_local;
