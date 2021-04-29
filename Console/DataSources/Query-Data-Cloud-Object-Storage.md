# Query Data on External Object Storage

## Introduction

The following examples demonstrate how to access data stored on cloud object stores. You can copy and modify the example queries below to access your own datasets. For simplicity, datasets are are provided by a public access bucket that does not require setup or credentials.

**Tip**:  For examples that demonstrate how to copy data from Vantage to a cloud object store, see: [Write Data to a Cloud Object Store](../DataSources/Write-Data-Cloud-Object-Storage.md).

To use SQL to access your own cloud object store, replace the following:
* **LOCATION** - Replace with the location of your object store. The location must begin with /s3/ (Amazon) or /az/ (Azure).
* **AUTHORIXATION** - Replace the empty **USER** and **PASSWORD** credentials with your **ACCESS_KEY_ID** and **SECRET_ACCESS-KEY**.

## Reading Cloud Object Storage Data

Parquet, CSV, and JSON file formats are supported when reading from cloud object storage. You can read data from a cloud object storage using READ_NOS or foreign tables.

### READ_NOS

READ_NOS allows you to do the following without needing to make changes in the database:
* Perform an ad hoc query on data stored on a cloud object store
* Examine the schema of the data files

### Foreign Tables

With CREATE TABLE privilege, you can create a foreign table inside the database, which provides an experience similar to working with local relational tables. Using a foreign table, you can do the following:
* Load external data to the database
* Join external data to data stored in the database
* Filter the data
* Use views to simplify how the data appears to users

Data read using Native Object Store is never persisted.

Data can be loaded into the database using INSERT SELECT and CREATE TABLE AS ... WITH DATA statements. 

## Set Up Secured Credentials Using an Authorization Object

Create an authorization object to contain the credentials to your external object store, and uncomment the EXTERNAL SECURITY clauses in the statements below to use.

```CREATE AUTHORIZATION InvAuth
USER 
PASSWORD;
```

## Read Data Stored on Amazon S3 Using READ_NOS

Select data from the cloud object store using READ_NOS:

```SELECT TOP 2* FROM(
LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
AUTHORIZATION=InvAuth
) AS D;
```

## Examine the Schema of Data Stored on Amazon S3 Using READ_NOS

Select only the schema of the data from the cloud object store using READ_NOS:

```SELECT TOP 1 * FROM (
LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
AUTHORIZATION=InvAuth
RETURNTYPE='NOSREAD_SCHEMA'
) AS D;
```

## Read Data Stored on Amazon S3 Using CREATE FOREIGN TABLE

Create a foreign table:

```CREATE FOREIGN TABLE sample_data
, EXTERNAL SECURITY InvAuth
USING (LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'));
Select data using the foreign table:
SELECT TOP 2*
FROM sample_data;

## Import Data into Vantage from Data Stored on Amazon S3

To persist data from a cloud object store, you can use a CREATE TABLE AS statement as follows:

```CREATE TABLE AS sample_data_local ( SELECT * FROM sample_data ) WITH DATA;
```