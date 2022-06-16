# Configure S3 Bucket Policy

To allow Teradata Vantage read and write access to your Amazon S3 data, your Cloud Administrator must ensure your Amazon S3 bucket policy is configured with the following actions for the role that allows access to the bucket:

* S3:GetObject
* S3:ListBucket
* S3:GetBucketLocation
* S3:putObject

**Tip**: If you use NOS while running demo use cases, you don't need to configure the policy because you are accessing a Teradata-managed Amazon S3 bucket.

**Resources**
 
* [Granting Access to Your Amazon S3 Bucket](https://docs.teradata.com/search/all?query=Granting+Access+to+Your+Amazon+S3+Bucket&content-lang=en-US)