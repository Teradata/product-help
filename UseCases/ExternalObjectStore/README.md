## Querying Data on External Object Storage

### Introduction

The following is a summary of how to access different formats of data stored in an external object store. You can copy and modify the example queries below to access your own datasets. For simplicity the included datasets are setup to not need credentials, but it is highly recommended that you use credentials to access your own datasets.

You can use similar SQL to access your own external object store. Simply replace the following:
* __LOCATION__ - Replace with the location of your object store. The location must begin with /s3/ (Amazon) or /az/ (Azure).
* __USER__ or __ACCESS_ID__ - Add the user name for your external object store.
* __PASSWORD__ or __ACCESS_KEY__ - Add the password of the user on your external object store.
* Uncomment the EXTERNAL SECURITY clause as necessary

When modifying to access your data - your external object store must be configured to allow access from the Vantage environment. Provide your credentials in USER and PASSWORD (used in the CREATE AUTHORIZATION command) and ACCESS_ID and ACCESS_KEY (used in the READ_NOS command).

### Accessing External Object Storage

There are two ways to read data from an external object store:

#### READ_NOS

READ_NOS allows you to do the following:
* Perform an ad hoc query on data that is in CSV and JSON formats with the data in-place on an external object store
* Examine the schema of PARQUET formatted data
* Bypass creating a foreign table in the database

#### Foreign Tables

Users with CREATE TABLE privilege can create a foreign table inside the database, point this virtual table to an external storage location, and use SQL to translate the external data into a form useful for business.
Using a foreign table in gives you the ability to:
* Load external data to the database
* Join external data to data stored in the database
* Filter the data
* Use views to simplify how the data appears to your users

Data read through a foreign server is not automatically stored on disk and the data can only be seen by that query. 

Data can be loaded into the database by selecting from READ_NOS or a Foreign Table in a CREATE TABLE AS ... WITH DATA statement. 

### When accessing your own data

Create an authorization object to contain the credentials to your external object store, and uncomment the EXTERNAL SECURITY clauses in the statements below to use.


```sql
CREATE AUTHORIZATION InvAuth
AS INVOKER TRUSTED
USER 'ACCESS_KEY_ID'
PASSWORD 'SECRET_ACCESS_KEY';
```

### Accessing CSV Data Stored on Amazon S3 with READ_NOS

Select data from external object store using READ_NOS:


```sql
SELECT TOP 2 payload..* FROM READ_NOS(
ON ( SELECT CAST( NULL AS DATASET STORAGE FORMAT CSV ) ) USING
LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/')
--ACCESS_ID ( 'ACCESS_KEY_ID' )
--ACCESS_KEY ( 'SECRET_ACCESS_KEY' ) 
) AS D;
```

### Accessing CSV Data Stored on Amazon S3 with CREATE FOREIGN TABLE

Create a foreign table:


```sql
CREATE FOREIGN TABLE sample_csv
--, EXTERNAL SECURITY INVOKER TRUSTED InvAuth
( Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC, Payload DATASET INLINE LENGTH 64000 STORAGE FORMAT CSV
)
USING (LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'));
```

View some data using the foreign table:


```sql
SELECT TOP 2 CAST(payload AS VARCHAR(64000))
FROM sample_csv;
```

### Import data into Vantage from CSV data stored on Amazon S3

To persist the data from an external object store we can use a CREATE TABLE AS statement as follows:

First we need a schema to apply to the data:


```sql
CREATE CSV SCHEMA sample_csv_schema AS
'{"field_delimiter":",","field_names":["date", "time", "epoch", "moteid", "temperature", "humidity", "light", "voltage"]}';
```

Create a foreign table that uses that schema:


```sql
CREATE FOREIGN TABLE sample_csv_ft
( Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC, 
  Payload DATASET INLINE LENGTH 64000 STORAGE FORMAT CSV WITH SCHEMA sample_csv_schema
)
USING (LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/data.csv'));
```

Create a view that splits out the CSV into individual columns:


```sql
REPLACE VIEW sample_csv_view
  AS 
    (SELECT
      CAST(payload.."date" AS DATE FORMAT 'YYYY-MM-DD') sensdate,
      CAST(payload.."time" AS TIME(6) FORMAT 'HH:MI:SSDS(F)') senstime,
      CAST(payload..epoch AS INTEGER) epoch,
      CAST(payload..moteid AS INTEGER) moteid,
      CAST(payload..temperature AS FLOAT) ( FORMAT '-ZZZ9.99') temperature,
      CAST(payload..humidity AS FLOAT) ( FORMAT '-ZZZ9.99') humidity,
      CAST(payload..light AS FLOAT) ( FORMAT '-ZZZ9.99') light,
      CAST(payload..voltage AS FLOAT) ( FORMAT '-ZZZ9.99') voltage,
      CAST(payload.."date" || ' ' || payload.."time" AS TIMESTAMP FORMAT 'YYYY-MM-DDBHH:MI:SSDS(F)') sensdatetime
  FROM sample_csv_ft);
```


```sql
SELECT TOP 2 *
FROM sample_csv_view;
```

### Accessing JSON Data Stored on Amazon S3 with READ_NOS

Select data from external object store using READ_NOS:


```sql
SELECT TOP 2 payload.* FROM READ_NOS (
ON ( SELECT CAST( NULL AS JSON ) )
USING
LOCATION ('/S3/s3.amazonaws.com/trial-datasets/EVCarBattery/')
--ACCESS_ID ( 'ACCESS_KEY_ID' )
--ACCESS_KEY ( 'SECRET_ACCESS_KEY' ) 
) AS D
```

### Accessing JSON Data Stored on Amazon S3 with CREATE FOREIGN TABLE

Create a foreign table:


```sql
CREATE FOREIGN TABLE sample_json
--, EXTERNAL SECURITY INVOKER TRUSTED InvAuth
(
LOCATION VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC , Payload JSON INLINE LENGTH 32000 CHARACTER SET UNICODE )
USING(
LOCATION('/S3/s3.amazonaws.com/trial-datasets/EVCarBattery/') )
```

View some data using the foreign table:


```sql
SELECT TOP 2 * FROM sample_json
```

### Exploring Parquet Data Stored on Amazon S3 with READ_NOS

See what files are in the Parquet bucket:


```sql
SELECT location(char(255)), ObjectLength 
FROM read_nos (
ON (select cast(NULL AS DATASET INLINE LENGTH 64000 STORAGE FORMAT CSV))
USING 
 LOCATION  ('/S3/s3.amazonaws.com/trial-datasets/SalesOffload/')
 RETURNTYPE ('NOSREAD_KEYS')
 --ACCESS_ID ( 'ACCESS_KEY_ID' )
 --ACCESS_KEY ( 'SECRET_ACCESS_KEY' ) 
) AS D
ORDER BY 1
```

See what the schema of the data is (specify one file - assuming all files in the bucket are formatted the same):


```sql
SELECT * FROM READ_NOS (
      USING
      LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload/2010/1/object_33_0_1.parquet')
      RETURNTYPE ('NOSREAD_PARQUET_SCHEMA')
      FULLSCAN ('TRUE')
      --ACCESS_ID ( 'ACCESS_KEY_ID' )
      --ACCESS_KEY ( 'SECRET_ACCESS_KEY' ) 
) AS D
```

### Accessing Parquet Data Stored on Amazon S3 with CREATE FOREIGN TABLE

Create a foreign table:


```sql
CREATE FOREIGN TABLE sample_parquet
--, EXTERNAL SECURITY INVOKER TRUSTED InvAuth
(
Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
TheYear INTEGER,
TheMonth INTEGER,
sales_date DATE FORMAT 'YY/MM/DD',
customer_id INTEGER,
store_id INTEGER,
basket_id INTEGER,
product_id INTEGER,
sales_quantity INTEGER,
discount_amount FLOAT FORMAT '-ZZZ9.99'
)
USING (
LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload')
STOREDAS  ('PARQUET'))
NO PRIMARY INDEX
PARTITION BY COLUMN
```

View some data using the foreign table:


```sql
SELECT TOP 2 * FROM sample_parquet
```

# Writing Data to an External Object Store
    
## Introduction

The following is a summary of how to copy data from Vantage to an external object store. You must provide your own bucket to execute the example queries below."

## WRITE_NOS

WRITE_NOS allows you to do the following:
* Copy / write data directly to an object store
* Convert the data in uncompressed Parquet format unless Snappy compression is specified by the user
* Specify one or more columns in the source table as partition attributes in the target object store
* Create and update of manifest files with all objects created during the copy process

Before running the following examples, replace the following fields in the example scripts:
* *YourBucketName* : with the name of your bucket
* *AccessID* : from the Access Key for your bucket - Access key ID example: AKIAIOSFODNN7EXAMPLE
* *AccessKey* : from the Access Key for your bucket - Secret Access Key example: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### Example 1 
This first example will select all rows in local sample_csv_local to copy the dataset to the object store's *sample1* partition:

```sql
SELECT * FROM WRITE_NOS (
    ON ( SELECT * FROM sample_csv_local )
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
        AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        STOREDAS ('PARQUET')
) AS d;
```

### Example 2 

This second example will copy the same dataset, this time partitioning by the sensor date year under the *sample2* partition:

```sql
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
         FROM sample_csv_local )
    PARTITION BY TheYear ORDER BY TheYear
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample2/')
        AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        NAMING ('DISCRETE')
        INCLUDE_ORDERING ('FALSE')
        STOREDAS ('PARQUET')
 AS d;
```

### Validate your WRITE_NOS results

You can validate the results of your WRITE_NOS use cases by creating an authorization object with your bucket user credentails and then creating a foreign table for accessing Parquet data as described in the examples in the above section. 


### Clean-up

Drop the objects we created in our own database schema.


```sql
DROP AUTHORIZATION InvAuth;
```

```sql
DROP TABLE sample_csv;
```

```sql
DROP VIEW sample_csv_view;
```

```sql
DROP TABLE sample_csv_ft;
```

```sql
DROP CSV SCHEMA sample_csv_schema;
```

```sql
DROP TABLE sample_json;
```

```sql
DROP TABLE sample_parquet;
```
