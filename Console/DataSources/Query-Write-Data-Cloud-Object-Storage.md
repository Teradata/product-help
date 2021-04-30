# Native Object Store Integration With Cloud Object Storage
- [Query Data on Cloud Object Storage](#query-data-on-cloud-object-storage)
- [Write Data to a Cloud Object Store](#write-data-to-a-cloud-object-store)

## Query Data on Cloud Object Storage

### Introduction

The following examples demonstrate how to access data stored on cloud object stores. You can copy and modify the example queries below to access your own datasets. For simplicity, sample datasets are provided through a public access bucket that does not require setup or credentials.

To use SQL to access your own cloud object store, replace the following:
* **LOCATION** - Replace with the location of your object store. The location must begin with /s3/ (Amazon) or /az/ (Azure).
* **AUTHORIZATION** - Replace the empty **USER** and **PASSWORD** credentials with your **ACCESS_KEY_ID** and **SECRET_ACCESS-KEY**.

**Note**: The AUTHORIZATION parameter is required only if you are not using IAM roles and policies to manage security. 

## Reading Cloud Object Storage Data

Parquet, CSV, and JSON file formats are supported when reading from cloud object storage. You can read data from a cloud object storage using READ_NOS or foreign tables.

#### READ_NOS

READ_NOS allows you to do the following without needing to make changes in the database:
* Perform an ad hoc query on data stored on a cloud object store
* Examine the schema of the data files

#### Foreign Tables

With CREATE TABLE privilege, you can create a foreign table inside the database, which provides an experience similar to working with local relational tables. Using a foreign table, you can do the following:
* Load external data to the database
* Join external data to data stored in the database
* Filter the data
* Use views to simplify how the data appears to users

Data read using Native Object Store is never persisted.

Data can be loaded into the database using INSERT SELECT and CREATE TABLE AS ... WITH DATA statements. 

### Set Up Secured Credentials Using an Authorization Object

Creating an authorization object enables you to securely store and reference the credentials to your cloud object store within Vantage. Keep in mind that our sample datasets are provided to you through a public access bucket for which no credentials are required.

```
CREATE AUTHORIZATION InvAuth
USER ''
PASSWORD '';
```

### Read Data Stored on Amazon S3 Using READ_NOS

Select data from the cloud object store using READ_NOS:

```
SELECT TOP 2* FROM(
LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
AUTHORIZATION=InvAuth
) AS D;
```

### Examine the Schema of Data Stored on Amazon S3 Using READ_NOS

Select only the schema of the data from the cloud object store using READ_NOS:

```
SELECT TOP 1 * FROM (
LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
AUTHORIZATION=InvAuth
RETURNTYPE='NOSREAD_SCHEMA'
) AS d;
```

### Read Data Stored on Amazon S3 Using CREATE FOREIGN TABLE

Create a foreign table:

```
CREATE FOREIGN TABLE sample_data
,EXTERNAL SECURITY InvAuth
USING ( LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/') );
```

Select data using the foreign table:

```
SELECT TOP 2
FROM sample_data;
```

### Import Data into Vantage from Data Stored on Amazon S3

To persist data from a cloud object store, use a CREATE TABLE AS statement:

```
CREATE TABLE AS sample_data_local ( SELECT * FROM sample_data ) WITH DATA;
```

## Write Data to a Cloud Object Store
    
### Introduction

The following examples demonstrate how to copy data from Vantage to a cloud object store. You must provide your own bucket to execute the example queries.

### WRITE_NOS

With WRITE_NOS, you can do the following:
* Copy / write data directly to a cloud object store
* Convert the data in uncompressed Parquet format unless Snappy compression is specified by the user
* Specify one or more columns in the source table as partition attributes in the target cloud object store
* Create and update a manifest file with all objects created during the copy process

Before running the examples, replace the following fields in the example scripts:
* *YourBucketName* : with the name of your bucket
* *AccessID* : from the Access Key for your bucket - Access key ID example: AKIAIOSFODNN7EXAMPLE
* *AccessKey* : from the Access Key for your bucket - Secret Access Key example: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

**Tip**:  As an alternative to the *AccessID* and *AccessKey* lines, you can create an authorization object to securely hide the credentials of your cloud object store.

#### Example 1 
This example selects all rows in local sample_data_local to copy the dataset to the object store's *sample1* partition:

```
sql
SELECT * FROM WRITE_NOS (
    ON ( SELECT * FROM sample_data_local )
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
        AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        --if using the authorization object, replace the line above with the line below minus the two dashes in front of the line:
        --AUTHORIZATION (authorization_object_name)        
        STOREDAS ('PARQUET')
) AS d;
```

#### Example 2 

This example copies the same dataset by partitioning by the sensor date year under the *sample2* partition:

```
sql
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
```

### Validate WRITE_NOS results

You can validate the results of your WRITE_NOS use cases by reading your Parquet data as described in the READ_NOS examples here: [Query Data on Cloud Object Storage](#query-data-on-cloud-object-storage)

### Clean Up

Drop the objects created in your own database schema:

```
DROP AUTHORIZATION InvAuth;
DROP TABLE sample_data;
DROP TABLE sample_data_local;
```