### Storing Data In VantageCloud Lake Edition Object File System

### Before You Begin

Open Editor to proceed with this use case. [LAUNCH EDITOR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introduction

The following is a summary of how to store data in VantageCloud Lake Edition Object File System (OFS).

### Setup

Create a foreign table with data in S3 bucket.

``` sourceCode
REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
CREATE FOREIGN TABLE foreign_csvdata
,EXTERNAL SECURITY DefaultAuth
USING (location('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'));
```

Check the data in foreign table.

``` sourceCode
SELECT * FROM foreign_csvdata;
```

### Scenario 1

If you have an existing foreign table with data in S3 bucket and want to load the data into a new OFS table, you can use the following statement.

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata )
WITH DATA;
```

Check the data in the new OFS table.

``` sourceCode
SELECT * FROM ofs_csvdata;
```

Drop the OFS table.

``` sourceCode
DROP TABLE ofs_csvdata;
```

### Scenario 2

If you have an existing Lake File System OFS table and want to load data from another table into it, then you can use the following statement.

Create a new OFS table.

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata,
     STORAGE = TD_OFSSTORAGE
     (
      site_no INTEGER,
      datetime TIMESTAMP(0),
      Precipitation DECIMAL(3,2),
      GageHeight DECIMAL(3,2),
      Flow DECIMAL(3,2),
      GageHeight2 DECIMAL(3,2))
NO PRIMARY INDEX ;
```

Load data from foreign table into the OFS table.

``` sourceCode
INSERT INTO ofs_csvdata SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata;
```

Check the data in the OFS table.

``` sourceCode
SELECT * FROM ofs_csvdata;
```

Drop the tables.

``` sourceCode
DROP TABLE ofs_csvdata;
DROP TABLE foreign_csvdata;
```

### Scenario 3

If you want to load data from an object store into a new OFS table for the first time, you can use the following statement.

To use this option you would need EXECUTE permission on TD\_SYSFNLIB.READ\_NOS. Which can be granted by following statement, work with your Database administrator to get the permission.

``` sourceCode
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <username>;
```

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2
FROM (
LOCATION='/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'
AUTHORIZATION=DefaultAuth
) AS d
) WITH DATA;
```

Check the data in the new OFS table

``` sourceCode
SELECT * FROM ofs_csvdata;
```

Drop the tables.

``` sourceCode
DROP TABLE ofs_csvdata;
```
