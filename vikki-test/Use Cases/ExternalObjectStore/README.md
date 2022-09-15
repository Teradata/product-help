## Data on an External Object Store

As a business analyst, there's times you want to access different formats of data in an object store or copy and write data to an object store. You can use the sample datasets provided in this use case without credentials or modify the samples to acess your own datasets with your credentials. 

If you want to modify the sample datsets to access your own data, your object store must be configured to allow access from the Vantage environment. Provide your credentials one of the following ways:

* USER and PASSWORD (in the CREATE AUTHORIZATION command)
* AUTHORIZATION simple syntax (in the READ_NOS command to skip the Authorization Object)

You can use similar SQL to access your own object stores by replacing the following:

* __LOCATION__: Replace with the location of your object store. The location must begin with /s3/ (Amazon), /az/ (Azure), or /gs/ (Google).
* __USER__ or __ACCESS_ID__: Add the username for your object store.
* __PASSWORD__ or __ACCESS_KEY__: Add the password of the user on your object store.
* __SESSION_TOKEN__: [Optionl]: Add a session token if you're  AWS Service Token Service to provide the access credentials.

Uncomment the EXTERNAL SECURITY clause if necessary.

## Before You Begin

1. Open Editor and log in using your DBC credentials.

   [LAUNCH EDITOR]

2. Load the built-in data set assets.

   [LOAD ASSETS]
   
## Walkthrough

* This use case takes approximately 15 minutes, depending on the dataset you use.
* This use case includes examples that can be done in any order and examples with steps in a particular order. When you are finished, clean up the objects.
* Copy, paste, optionally edit, and run the code in Editor to follow along.
  
### Example 1: Access object storage.

You can read data from an object store using READ_NOS or foreign tables.

#### READ_NOS

With READ_NOS, you can do the following:

* Perform an adhoc query on data that is in Parquet, CSV, and JSON formats with the data currently in an object store.
* Examine the structure of the object store.
* Examine the schema of the formatted data.
* Bypass creating a foreign table in the database.

#### Foreign Tables

If you have CREATE TABLE privileges, you can create a foreign table inside the database, point the virtual table to an object store location, then use SQL to translate the data into a form useful for your business.

With a foreign table, you can do the following:

* Load external data to the database.
* Join external data to data stored in the database.
* Filter the data.
* Use views to simplify how the data appears or provide added security access controls.

Data read through a foreign server is not persisted and can be seen by only that query.

Data can be loaded into the database by selecting from READ_NOS or a foreign table in a CREATE TABLE AS ... WITH DATA statement. 

### Exmaple 2: Acess your own data.

Create an authorization object that the credentials for your external object store and uncomment the EXTERNAL SECURITY clauses in the following statements:

```sql
DATABASE <database_name>;

CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

### Example 3: Access data stored on Amazon S3 with READ_NOS.

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

### Example 4: Access data stored on Amazon S3 with CREATE FOREIGN TABLE.

```sql
CREATE FOREIGN TABLE sample_table
, EXTERNAL SECURITY MyAuth
USING (LOCATION('/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'));
```

View some of the data using the foreign table:

```sql
SELECT TOP 2 * FROM sample_table;
```

### Example 5: Import data into Vantage from data stored on Amazon S3.

To persist the data from an object store, use a CREATE TABLE AS statement:

```sql
CREATE MULTISET TABLE sample_local_table AS (
  SELECT * FROM (
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
    AUTHORIZATION=MyAuth
  ) AS D
) WITH DATA;
```

## Write or Copy Data Using WRITE_NOS
    
WRITE_NOS allows you to do the following:

* Copy and write data directly to an object store.
* Convert the data in uncompressed Parquet format, unless Snappy compression is specified.
* Specify one or more columns in the source table as partition attributes in the target object store.
* Create and update of manifest files with all objects created during the copy process.

You must provide your own bucket to execute the sample queries. Before running the examples, replace the following fields in the example scripts:

* *YourBucketName* : with the name of your bucket
* *YourAuthObject* : your authorization object containing your storage credentials
* [optionally] *AccessID* : from the Access Key for your bucket - Access key ID example: AKIAIOSFODNN7EXAMPLE
* [optionally] *AccessKey* : from the Access Key for your bucket - Secret Access Key example: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### Step 1: Select all rows and copy the data set.

Select all rows in local sample_csv_local to copy the dataset to the object store's *sample1* partition:

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

### Step 2: Copy the dataset:

Copy the same dataset and partition by the sensor date year under the *sample2* partition:

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

### Step 3: Validate WRITE_NOS results.

You can validate the results of your WRITE_NOS use cases by creating an authorization object with your bucket user credentails, then creating a foreign table for accessing Parquet data as described in the previous examples. 

### Clean up objects. 

Drop the objects you created in your database schema:

```sql
DROP AUTHORIZATION MyAuth;
```

```sql
DROP TABLE sample_table;
```

```sql
DROP TABLE sample_local_table;
```
