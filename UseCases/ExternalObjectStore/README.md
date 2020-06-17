## Querying Data on External Object Storage


### Introduction

The following examples show how to access different formats of data stored in an Amazon S3 bucket. We will be using a sample river flow data set from the U.S Geological Survey. Copy and modify the example queries below to access your own datasets.

You can use the same SQL to access your own external object store. Simply replace the following:
* __LOCATION__ - Replace with the location of your object store. The location must begin with /s3 (Amazon) or /az (Azure).
* __USER__ or __ACCESS_ID__ - Replace with the user name for your external object store.
* __PASSWORD__ or __ACCESS_KEY__ - Replace with the password of the user on your external object store.

Your external object store must be configured to allow access.
When you configure external storage, you set the credentials that are used in SQL statements by . The supported credentials for USER and PASSWORD (used in the CREATE AUTHORIZATION command) and ACCESS_ID and ACCESS_KEY (used in the READ_NOS command) correspond to the values shown in the following table:

### Accessing External Object Storage

There are two ways to read data from an external object store:

#### READ_NOS

READ_NOS allows you to do the following:
* Perform an ad hoc query on data that is in CSV and JSON formats with the data in-place on an external object store
* Bypass creating a foreign table in the database

#### Foreign Tables

Users with CREATE TABLE privilege can create a foreign table inside the database, point this virtual table to an external storage location, and use SQL to translate the external data into a form useful for business.
Using a foreign table in gives you the ability to:
* Load external data to the database
* Join external data to data stored in the database
* Filter the data
* Use views to simplify how the data appears to your users
Data read through a foreign server is not automatically stored on disk and the data can only be seen by that query. Data can be loaded into the database by accessing a foreign table in the CREATE TABLE AS ...WITH DATA command.can use Vantage and the structured and semi-structured data that we capture in the manufacturing process order to isolate and address this issue.

### Accessing CSV Data Stored on Amazon S3 with READ_NOS

```sql
SELECT TOP 2 payload..* FROM READ_NOS(
ON ( SELECT CAST( NULL AS DATASET STORAGE FORMAT CSV ) ) USING
LOCATION('/s3/s3.amazonaws.com/td-usgs/CSVDATA/')
ACCESS_ID ( 'AKIAXOX5JIKEOTFWW4UL' )
ACCESS_KEY ( 'HD9ld0x9nGaU2M8c2OnzINsn4Xjp7vt+RIAJJCIO' ) ) AS D
```


### Accessing CSV Data Stored on Amazon S3 with CREATE FOREIGN TABLE

Create an authorization object to contain the credentials to the external object store:


```sql
CREATE AUTHORIZATION InvAuth
AS INVOKER TRUSTED
USER 'AKIAXOX5JIKEOTFWW4UL'
PASSWORD 'HD9ld0x9nGaU2M8c2OnzINsn4Xjp7vt+RIAJJCIO';
```

Create a foreign table:


```sql
CREATE FOREIGN TABLE riverflow_csv
, EXTERNAL SECURITY INVOKER TRUSTED InvAuth
( Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC, Payload DATASET INLINE LENGTH 64000 STORAGE FORMAT CSV
)
USING (LOCATION('/s3/s3.amazonaws.com/td-usgs/CSVDATA/'));
```

View some data using the foreign table:


```sql
SELECT TOP 2 payload
FROM riverflow_csv;
```

### Accessing JSON Data Stored on Amazon S3 with READ_NOS

Select data from external object store using READ_NOS:


```sql
SELECT TOP 2 payload.* FROM READ_NOS (
ON ( SELECT CAST( NULL AS JSON ) )
USING
LOCATION ('/S3/s3.amazonaws.com/td-usgs/JSONDATA/')
ACCESS_ID ( 'AKIAXOX5JIKEOTFWW4UL' )
ACCESS_KEY ( 'HD9ld0x9nGaU2M8c2OnzINsn4Xjp7vt+RIAJJCIO' ) ) AS D
```


### Accessing JSON Data Stored on Amazon S3 with CREATE FOREIGN TABLE

Create a foreign table:


```sql
CREATE FOREIGN TABLE riverflow_json
, EXTERNAL SECURITY INVOKER TRUSTED InvAuth
(
LOCATION VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC , Payload JSON INLINE LENGTH 32000 CHARACTER SET UNICODE )
USING(
LOCATION('/S3/s3.amazonaws.com/td-usgs/JSONDATA/') )
```


View some data using the foreign table:


```sql
SELECT TOP 2 * FROM riverflow_json
```


### Exploring Parquet Data Stored on Amazon S3 with READ_NOS

See what files are in the Parquet bucket:


```sql
SELECT location(char(255)), ObjectLength 
FROM read_nos (
ON (select cast(NULL AS DATASET INLINE LENGTH 64000 STORAGE FORMAT CSV))
USING 
 LOCATION  ('/S3/s3.amazonaws.com/td-usgs/PARQUETDATA/')
 RETURNTYPE ('NOSREAD_KEYS')
 ACCESS_ID ( 'AKIAXOX5JIKEOTFWW4UL' )
 ACCESS_KEY ( 'HD9ld0x9nGaU2M8c2OnzINsn4Xjp7vt+RIAJJCIO' ) ) AS D
ORDER BY 1
```


See what the schema of the data is (specify one file - assuming all files in the bucket are formatted the same):


```sql
SELECT * FROM READ_NOS (
      USING
      LOCATION  ('/S3/s3.amazonaws.com/td-usgs/PARQUETDATA/09394500/2018/06/27.parquet')
      RETURNTYPE ('NOSREAD_PARQUET_SCHEMA')
      FULLSCAN ('TRUE')
      ACCESS_ID ( 'AKIAXOX5JIKEOTFWW4UL' )
      ACCESS_KEY ( 'HD9ld0x9nGaU2M8c2OnzINsn4Xjp7vt+RIAJJCIO' ) ) AS D
```

### Accessing Parquet Data Stored on Amazon S3 with CREATE FOREIGN TABLE

Create a foreign table:


```sql
CREATE FOREIGN TABLE riverflow_parquet
, EXTERNAL SECURITY INVOKER TRUSTED InvAuth
(
Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC
, GageHeight2 DOUBLE PRECISION FORMAT '-ZZZ9.99'
, Flow DOUBLE PRECISION FORMAT '-ZZZZ9.99'
, site_no BIGINT
, datetime VARCHAR(16) CHARACTER SET UNICODE CASESPECIFIC
, Precipitation DOUBLE PRECISION FORMAT '-ZZZ9.99'
, GageHeight DOUBLE PRECISION FORMAT '-ZZZ9.99'
)
USING (
LOCATION ('/S3/s3.amazonaws.com/td-usgs/PARQUETDATA/') STOREDAS ('PARQUET')
) NO PRIMARY INDEX
, PARTITION BY COLUMN 
```

View some data using the foreign table:


```sql
SELECT TOP 2 * FROM riverflow_parquet
```


### Clean-up

Drop the objects we created in our own database schema.


```sql
DROP AUTHORIZATION InvAuth
```

```sql
DROP TABLE riverflow_csv
```

```sql
DROP TABLE riverflow_json
```

```sql
DROP TABLE riverflow_parquet
```
