配置 S3 存储桶策略
==================

要允许 Teradata Vantage 读取和写入 Amazon S3 数据，云管理员必须确保 S3 存储桶策略为允许访问存储桶的角色配置有以下操作：

-   S3:GetObject
-   S3:ListBucket
-   S3:GetBucketLocation
-   S3:putObject

**提示**：如果在运行演示用例时使用 NOS，则不需要配置策略，因为你要访问的是 Teradata 托管 Amazon S3 存储桶。

**资源**

-   [授予对 Amazon S3 存储桶的访问权限](https://docs.teradata.com/search/all?query=Granting+Access+to+Your+Amazon+S3+Bucket&content-lang=en-US)
