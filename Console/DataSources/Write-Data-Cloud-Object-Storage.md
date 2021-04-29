# Writing Data to a Cloud Object Store
    
## Introduction

The following examples demonstrate how to copy data from Vantage to a cloud object store. You must provide your own bucket to execute the example queries below.

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
