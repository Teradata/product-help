# Write Data to a Cloud Object Store
    
## Introduction

The following examples demonstrate how to copy data from Vantage to a cloud object store. You must provide your own bucket to execute the example queries below.

**Tip**:  For examples that demonstrate how to access data stored on cloud object stores, see: [Query Data on External Object Storage](../DataSources/Query-Data-Cloud-Object-Storage.md).

## WRITE_NOS

WRITE_NOS allows you to do the following:
* Copy / write data directly to a cloud object store
* Convert the data in uncompressed Parquet format unless Snappy compression is specified by the user
* Specify one or more columns in the source table as partition attributes in the target cloud object store
* Create and update a manifest file with all objects created during the copy process

Before running the following examples, replace the following fields in the example scripts:
* *YourBucketName* : with the name of your bucket
* *AccessID* : from the Access Key for your bucket - Access key ID example: AKIAIOSFODNN7EXAMPLE
* *AccessKey* : from the Access Key for your bucket - Secret Access Key example: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

**Tip**:  As an alternative to the *AccessID* and *AccessKey* lines above, you can create an authorization object to securely hide the credentials of your cloud object store.

### Example 1 
This example selects all rows in local sample_data_local to copy the dataset to the object store's *sample1* partition:

```sql
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

### Example 2 

This example copies the same dataset by partitioning by the sensor date year under the *sample2* partition:

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

You can validate the results of your WRITE_NOS use cases by creating an authorization object with your bucket user credentials, then creating a foreign table for accessing Parquet data as shown in the examples here: [Query Data on External Object Storage](../DataSources/Query-Data-Cloud-Object-Storage.md).


### Clean Up

Drop the objects created in your own database schema:

```DROP AUTHORIZATION InvAuth;
DROP TABLE sample_data;
DROP TABLE sample_data_local;
```
