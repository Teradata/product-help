### Storing Data In VantageCloud Lake Edition Lake File System

Option 1:
 
Setup steps:
 
```sql 
CREATE FOREIGN TABLE csvdata
,EXTERNAL SECURITY retail_sample_data.DEMO_AUTH_NOS
USING (location('/S3/s3.amazonaws.com/td-usgs-public/CSVDATA/'));
```
 
If you have an existing foreign table to an existing S3 bucket, to load this data into a new Lake File System table, you can use the following statement:

```sql 
CREATE MULTISET TABLE localcsv
,STORAGE = TD_NOSFS_STORAGE
AS ( SELECT site_no,datetime,Precipitation,GageHeight,Flow,GageHeight2 FROM csvdata )
WITH DATA;
```
 
Option 2:
 
If you have an existing Lake File System table and you want to load new data into it, then you can use the following statement:
 
```sql
INSERT INTO localcsv SELECT site_no,datetime,Precipitation,GageHeight,Flow,GageHeight2 FROM csvdata;
```
 
Option 3:
 
If you do want to load new data from an object store into a new table for the first time, you can use the following statement:
 
```sql
CREATE MULTISET TABLE localcsv
,STORAGE = TD_NOSFS_STORAGE
AS ( SELECT site_no,datetime,Precipitation,GageHeight,Flow,GageHeight2
FROM (
LOCATION='/S3/s3.amazonaws.com/td-usgs-public/CSVDATA/'
AUTHORIZATION='{"access_id":"","access_key":""}'
) AS d
) WITH DATA;
```