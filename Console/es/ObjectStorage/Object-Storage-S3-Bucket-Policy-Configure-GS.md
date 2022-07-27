Configurar la política de buckets de S3
=======================================

Para permitir el acceso de lectura y escritura de Teradata Vantage a tus datos de Amazon S3, tu administrador de servicios en la nube debe asegurarse de que tu política de buckets de Amazon S3 está configurada con las siguientes acciones para el rol que permite el acceso al bucket:

-   S3:GetObject
-   S3:ListBucket
-   S3:GetBucketLocation
-   S3:putObject

**Consejo**: si utilizas NOS mientras ejecutas casos de uso de demostración, no necesitas configurar la política porque estarás accediendo a un bucket de Amazon S3 administrado por Teradata.

**Recursos**

-   [Concesión de acceso a tu bucket de Amazon S3](https://docs.teradata.com/search/all?query=Granting+Access+to+Your+Amazon+S3+Bucket&content-lang=en-US)
