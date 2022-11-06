Um Teradata Vantage Lese- und Schreibzugriff auf Ihre Amazon S3-Daten zu ermöglichen, muss Ihr Cloud-Administrator sicherstellen, dass Ihre Amazon S3-Bucket-Richtlinie mit den folgenden Aktionen für die Rolle konfiguriert ist, die den Zugriff auf den Bucket erlaubt:

-   S3:GetObject
-   S3:ListBucket
-   S3:GetBucketLocation
-   S3:putObject

**Tipp**: Wenn Sie NOS bei der Ausführung von Demo-Anwendungsfällen verwenden, brauchen Sie die Richtlinie nicht zu konfigurieren, da Sie auf einen von Teradata verwalteten Amazon S3-Bucket zugreifen.

**Ressourcen**

-   [Zugriff auf Ihr Amazon S3-Bucket gewähren](https://docs.teradata.com/search/all?query=Granting+Access+to+Your+Amazon+S3+Bucket&content-lang=en-US)
