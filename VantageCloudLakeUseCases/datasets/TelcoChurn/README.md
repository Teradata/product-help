
# TelcoChurn Dataset


TelcoChurn dataset is used in telecommunications use cases.


To refresh the data in S3

```
aws s3 rm s3://${S3_BUCKET}/TelcoChurn --recursive   

aws s3 cp data/* s3://${S3_BUCKET}/TelcoChurn/ 

```
Because we are using an authorization this is not needed but if we wanted to make the files publicly accessible then we would add this to the s3 cp call
```
--acl public-read    
```


The SQl files in the scripts folder are idempotent which means no matter how many times you run
them they should be rerunnable and the state of the tables will be the same after each run.
To accomplish this we delete the objects and recreate them on each run.
When the query to delete the object is run we would ignore any errors that the object does not exist but
we should handle errors where the user doesn't have the correct permissions.





