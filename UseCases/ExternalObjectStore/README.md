## Querying Data on External Object Storage

### Introduction

Learn how to access different formats of data stored in an object store. You can copy and modify the example queries to access your own datasets. For simplicity, datasets included do not require credentials, but we recommend that you use credentials to access your own datasets.

You can use similar SQL to access your own object stores by replacing the following:
* __LOCATION__ - Replace with the location of your object store. The location must begin with /s3/ (Amazon), /az/ (Azure), or /gs/ (Google).
* __USER__ or __ACCESS_ID__ - Add the username for your object store.
* __PASSWORD__ or __ACCESS_KEY__ - Add the password for the user on your object store.
* __SESSION_TOKEN__ - Optionally add a session token to provide access credentials if you are using AWS Service Token Service.
* Uncomment the EXTERNAL SECURITY clause as necessary.

When modifying queries to access your data, your object store must be configured to allow access from the Vantage environment. Provide your credentials in USER and PASSWORD (used in the CREATE AUTHORIZATION command) or AUTHORIZATION simple syntax (used in the READ_NOS command if you don't want to use the Authorization Object).

### Accessing Object Storage

There are two ways to read data from an object store:

#### READ_NOS

READ_NOS enables you to do the following:
* Perform an ad hoc query on data that is in Parquet, CSV, or JSON formats with the data on an object store.
* Examine the structure (layout) of the object store.
* Examine the schema of the formatted data.
* Bypass creating a foreign table in the database.

#### Foreign Tables

Users with CREATE TABLE privilege can create a foreign table inside the database, point this virtual table to an object store location, and use SQL to translate the data into a form useful for business.
Foreign table enable you to do the following:
* Load external data to the database.
* Join external data to data stored in the database.
* Filter data.
* Use views to simplify how data appears to your users or provide added security access controls.

Data read through a foreign server is not persisted and can be seen only by that query.

Data can be loaded into the database by selecting from READ_NOS or a Foreign Table in a CREATE TABLE AS ... WITH DATA statement. 

### Accessing Your Own Data

Create an authorization object that contains the credentials for your external object store and uncomment the EXTERNAL SECURITY clauses in the following statements:


```sql
CREATE AUTHORIZATION MyAuth
USER 'ACCESS_KEY_ID'
PASSWORD 'SECRET_ACCESS_KEY';
```

### Accessing Data Stored on Amazon S3 with READ_NOS

Select data from external object store using READ_NOS:


```sql
SELECT TOP 2 * FROM (
LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
AUTHORIZATION=MyAuth
--AUTHORIZATION='{"access_id":"ACCESS_KEY_ID","access_key":"SECRET_ACCESS_KEY"}'  --[optional AUTHORIZATION using direct credentials]
--RETURNTYPE='NOSREAD_KEY'  --[optional if wanting to list the layout of the object store]
--RETURNTYPE='NOSREAD_SCHEMA'  --[optional if wanting to display the schema of the data files] 
) AS D;
```

### Accessing Data Stored on Amazon S3 with CREATE FOREIGN TABLE

Create a foreign table:


```sql
CREATE FOREIGN TABLE sample_table
--, EXTERNAL SECURITY MyAuth
USING (LOCATION('/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'));
```

View some data using the foreign table:


```sql
SELECT TOP 2 * FROM sample_table;
```

### Importing Data Into Vantage From Data Stored on Amazon S3

To persist data from an object store, use the following CREATE TABLE AS statement:

```CREATE MULTISET TABLE sample_local_table AS (
  SELECT * FROM (
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
    AUTHORIZATION=MyAuth
  ) AS D
) WITH DATA;
```


# Writing Data to an Object Store
    
## Introduction

Learn how to copy data from Vantage to an object store. You must provide your own bucket to execute the example queries below.

## WRITE_NOS

WRITE_NOS allows you to do the following:
* Copy or write data directly to an object store.
* Convert data in uncompressed Parquet format unless Snappy compression is specified by the user.
* Specify one or more columns in the source table as partition attributes in the target object store.
* Create and update manifest files with all objects created during the copy process.

Before running the following examples, replace these fields in the example scripts:
* *YourBucketName* - Name of your bucket
* *YourAuthObject* - Your authorization object that contains your storage credentials
* [optionally] *AccessID* - From the Access Key for your bucket - Access key ID example: AKIAIOSFODNN7EXAMPLE
* [optionally] *AccessKey* - From the Access Key for your bucket - Secret Access Key example: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### Example 1 
Example 1 selects all rows in local sample_csv_local to copy the dataset to the object store's *sample1* partition:

```sql
SELECT * FROM WRITE_NOS (
    ON ( SELECT * FROM sample_csv_local )
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
        AUTHORIZATION (MyAuth)
--      AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        STOREDAS ('PARQUET')
) AS d;
```

### Example 2 

Example 2 copies the same dataset, this time partitioning by the sensor date year under the *sample2* partition:

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
        AUTHORIZATION (MyAuth)
--      AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        NAMING ('DISCRETE')
        INCLUDE_ORDERING ('FALSE')
        STOREDAS ('PARQUET')
 AS d;
```

### Validating Your WRITE_NOS Results

Validate results of your WRITE_NOS use cases by creating an authorization object with your bucket user credentails and then creating a foreign table for accessing Parquet data as described in the examples above. 


### Cleanup

Drop the objects you created in your own database schema:


```sql
DROP AUTHORIZATION MyAuth;
```

```sql
DROP TABLE sample_table;
```

```sql
DROP TABLE sample_local_table;
```
