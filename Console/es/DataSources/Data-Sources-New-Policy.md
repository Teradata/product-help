Para permitir el acceso de lectura y escritura de Teradata Vantage a tus datos de Amazon S3, tu administrador de servicios en la nube debe asegurarse de que tu política de buckets de Amazon S3 está configurada con las siguientes acciones para el rol que permite el acceso al bucket:

-   S3:GetObject
-   S3:ListBucket
-   S3:GetBucketLocation
-   S3:putObject
