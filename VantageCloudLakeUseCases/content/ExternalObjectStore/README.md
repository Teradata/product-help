## Working with external object stores: Reading and writing data 

### Before You Begin

Open Editor to proceed with this use case.
[LAUNCH EDITOR](#data={"navigateTo":"editor"})

### Introduction

This section shows how users can interact with open object stores. Teradata VantageCloud Lake provides native functions for both reading and writing data to these scalable, low-cost data stores, allowing users to easily integrate with vast amounts of data stored in data lakes, as well as offload archival or other data to these platforms. 

For evaluation purposes, Teradata has provided data in an open object store location. For real-world usage, users should provide login credentials or other role-based access to object storage. If you choose to use your own object store to query data, replace the following in the SQL code: 

* __LOCATION__ - Replace with the location of your object store. The location must begin with /s3/ (Amazon), /az/ (Azure), or /gs/ (Google).
* __USER__ or __ACCESS_ID__ - Add the username for your object store.
* __PASSWORD__ or __ACCESS_KEY__ - Add the password of the user on your object store.
* __SESSION_TOKEN__ - You can also add an optional session token if using AWS Security Token Service to provide you with the access credentials.
* Uncomment the EXTERNAL SECURITY clause as necessary

If you are modifying the SQL to access your own data in your object store, ensure it is configured to allow access from the VantageCloud Lake environment. Provide the proper credentials in the USER and PASSWORD elements in the CREATE AUTHORIZATION statement or in the JSON string argument of the AUTHORIZATION element used in the READ_NOS statement. 

To perform these use cases, the user needs specific permissions to the SQL functions used to read and write to external object stores. Execute the following statements as a database user with administrator privileges or ask a database administrator to run them for you. 

```sql
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <USERNAME>;
GRANT EXECUTE FUNCTION ON TD_SYSFNLIB.WRITE_NOS TO <USERNAME>; 
```

### Accessing object storage

There are two ways to read data from an object store:

#### READ_NOS

The READ_NOS Table Operator is a function which allows users to: 
* Perform an ad hoc query on data that is in Parquet, CSV, and JSON formats with the data in-place on an object store
* Examine the structure (layout) of the object store
* Examine the schema of the formatted data

```sql
--This SQL statement will query ten rows of data from the s3 bucket 
--defined in the LOCATION element 
SELECT TOP 10 * FROM ( 
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

To access external object stores that require authentication, create an authorization object.  This object will contain the credentials (username, password, session token, identity and access management (IAM) role, etc.) that the database needs to read (and/or write) data.  The following statement can be used to create an authorization object to contain the credentials to your external object store. Alternatively, credentials can be passed as a JSON-formatted string to the AUTHORIZATION element of the query. 

```sql
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```
### Using an authorization to access data stored on Amazon S3

```sql
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

Data can be loaded into the database by selecting from READ_NOS or a foreign table in a CREATE TABLE AS … WITH DATA statement. 

### Accessing data stored on Amazon S3 with CREATE FOREIGN TABLE

Create a foreign table:


```sql
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

```sql
SELECT TOP 2 * FROM sample_sensor;
```

### Importing data into VantageCloud Lake from data stored on Amazon S3

To persist the data from an object store, we can use a CREATE TABLE AS statement as follows. Embed the READ_NOS SELECT statement inside the CREATE TABLE AS, and be sure to include WITH DATA to insert all the rows into a local table:

```sql
CREATE MULTISET TABLE sample_local_table AS (
  SELECT * FROM (
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
    AUTHORIZATION=MyAuth
  ) AS D
) WITH DATA;
```


## Writing Data to an Object Store
    
### Introduction

The following is a summary of how to copy data from VantageCloud Lake to an object store. You must provide your own bucket and credentials (or authorization object) to execute the example queries below. 

The WRITE_NOS query returns the list of objects and their metadata written to the target object store. These results are useful for logging/traceability and other administrative and management use cases. 

#### WRITE_NOS

WRITE_NOS allows you to:
* Copy / write data directly to an object store
* Optionally compress the data
* Specify one or more columns in the source table as partition attributes in the target object store. Partition attributes will be used to generate additional object keys when writing the data. These keys can be used for efficient data organization and filtering for other systems reading the objects.
* Create and update of manifest files with all objects created during the copy process

Before running the following examples, replace the following fields in the example scripts:
* *YourBucketName* : Replace with the name of your bucket or blob store where you have write access
* For VantageCloud Lake to pass the proper credentials, you can either use an authorization object or pass the credentials as a JSON-formatted argument to the AUTHORIZATION element. 
* Replace with your authorization object containing your storage credentials, or: 
    * *AccessID* : from the Access Key for your bucket (optional) - Access key ID example: AKIAIOSFODNN7EXAMPLE
    * *AccessKey* : from the Access Key for your bucket (optional) - Secret Access Key example: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### Example 1 
This example will use the result of a SELECT statement that retrieves all rows in the __sample_sensor__ table (created above), and will write it to the *sample1* partition or container in the account or bucket specified in the LOCATION element: 

```sql
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

This example uses the same __sensor_data__ table as a source, this time partitioning by the sensor date year under the *sample2* partition: 

```sql
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

### Validate your WRITE_NOS results

You can validate the results of your WRITE_NOS use cases by creating an authorization object with your bucket user credentials and then creating a foreign table for accessing Parquet data as described in the examples in the above section, or by performing a simple SELECT statement using READ_NOS syntax from above. 


### Clean up

Drop the objects we created in our own database schema.


```sql
DROP AUTHORIZATION MyAuth;
```

```sql
DROP TABLE sample_sensor;
```

```sql
DROP TABLE sample_local_table;
```
