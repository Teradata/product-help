Pour autoriser l'accès en lecture et écriture de Teradata Vantage à vos données Amazon S3, votre administrateur du cloud doit veiller à ce que la stratégie de compartiment Amazon S3 soit configurée avec les actions suivantes pour le rôle qui autorise l'accès au compartiment :

-   S3:GetObject
-   S3:ListBucket
-   S3:GetBucketLocation
-   S3:putObject

**Conseil** : si vous utilisez NOS pendant l'exécution des cas d'utilisation de démonstration, il n'est pas nécessaire de configurer la stratégie, car vous accédez au compartiment Amazon S3 géré par Teradata.

**Ressources**

-   [Accord de l'accès à votre compartiment Amazon S3](https://docs.teradata.com/search/all?query=Granting+Access+to+Your+Amazon+S3+Bucket&content-lang=en-US)
