-   [Interroger des données dans le stockage d'objets du cloud](#query-data-on-cloud-object-storage)
-   [Écrire des données dans une banque d'objets du cloud](#write-data-to-a-cloud-object-store)

Interroger des données dans le stockage d'objets du cloud
---------------------------------------------------------

### Introduction

Les exemples suivants montrent comment accéder aux données stockées sur les banques d'objets du cloud. Vous pouvez copier et modifier les exemples de requêtes ci-dessous pour accéder à vos propres jeux de données. Par commodité, les exemples de jeux de données sont fournis par le biais d'un compartiment d'accès public qui ne nécessite ni configuration ni informations d'identification.

Pour accéder à votre banque d'objets du cloud via SQL, remplacez les éléments suivants : \* **LOCATION** - Remplacez-les par l'emplacement de la banque d'objets. L'emplacement doit commencer par /s3/ (Amazon) ou /az/ (Azure). \* **AUTHORIZATION** - Remplacez les informations d'identification **USER** et **PASSWORD** vides par **ACCESS\_KEY\_ID** et **SECRET\_ACCESS-KEY**.

**Remarque** : le paramètre AUTHORIZATION n'est requis que si vous n'utilisez pas les rôles IAM et les stratégies pour gérer la sécurité.

Lecture des données de stockage d'objets du cloud
-------------------------------------------------

Les formats de fichiers Parquet, CSV et JSON sont pris en charge pendant la lecture à partir du stockage d'objets du cloud. Vous pouvez lire les données à partir d'un stockage d'objets du cloud à l'aide des tables READ\_NOS ou étrangères.

#### READ\_NOS

READ\_NOS permet d'effectuer les opérations suivantes sans devoir modifier la base de données : \* Effectuer une requête ad hoc sur les données stockées dans une banque d'objets du cloud \* Examiner le schéma des fichiers de données

#### Tables étrangères

Le privilège CREATE TABLE permet de créer une table étrangère dans la base de données, ce qui apporte une expérience semblable à l'utilisation de tables relationnelles locales. La table étrangère permet d'effectuer les opérations suivantes : \* Charger des données externes dans la base de données \* Associer des données externes aux données stockées dans la base de données \* Filtrer les données \* Utiliser des vues pour simplifier le mode d'affichage des données aux utilisateurs

Les données lues à l'aide de la banque d'objets natifs ne sont jamais conservées.

Vous pouvez charger les données dans la base de données à l'aide des instructions INSERT SELECT et CREATE TABLE AS … WITH DATA.

### Configurer les informations d'identification sécurisées à l'aide d'un objet d'autorisation

La création d'un objet d'autorisation permet de stocker en toute sécurité les informations d'identification et de les référencer dans la banque d'objets du cloud de Vantage. Notez que nos exemples de jeux de données vous sont fournis par le biais d'un compartiment d'accès public pour lequel aucune information d'identification n'est requise.

    CREATE AUTHORIZATION InvAuth
    USER ''
    PASSWORD '';

### Lire des données stockées sur Amazon S3 à l'aide de READ\_NOS

Sélectionnez les données de la banque d'objets du cloud à l'aide de READ\_NOS :

    SELECT TOP 2 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    ) AS D;

### Examiner le schéma des données stockées sur Amazon S3 à l'aide de READ\_NOS

Sélectionnez uniquement le schéma de données de la banque d'objets du cloud à l'aide de READ\_NOS :

    SELECT TOP 1 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    RETURNTYPE='NOSREAD_SCHEMA'
    ) AS d;

### Lire des données stockées sur Amazon S3 à l'aide de CREATE FOREIGN TABLE

Créez une table étrangère :

    CREATE FOREIGN TABLE sample_data
    ,EXTERNAL SECURITY InvAuth
    USING ( LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/') );

Sélectionnez des données à l'aide de la table étrangère :

    SELECT TOP 2 * FROM sample_data;

### Importer des données dans Vantage à partir des données stockées dans Amazon S3

Pour conserver les données d'une banque d'objets du cloud, utilisez une instruction CREATE TABLE AS :

    CREATE TABLE AS sample_data_local ( SELECT * FROM sample_data ) WITH DATA;

Écrire des données dans une banque d'objets du cloud
----------------------------------------------------

### Introduction

Les exemples suivants montrent comment copier des données de Vantage vers une banque d'objets de cloud. Vous devez fournir votre propre compartiment pour exécuter les exemples de requêtes.

### WRITE\_NOS

Avec WRITE\_NOS, vous pouvez effectuer les opérations suivantes : \* Copier/écrire des données directement dans une banque d'objets du cloud \* Convertir les données en format Parquet non compressé sauf si l'utilisateur précise la compression Snappy \* Indiquer une ou plusieurs colonnes dans la table source comme attributs de partition dans la banque d'objets du cloud cible \* Créer et mettre à jour un fichier de manifeste avec tous les objets créés pendant le processus de copie

Avant d'exécuter les exemples, remplacez les champs suivants dans les exemples de scripts : \* *YourBucketName* : par le nom du compartiment \* *AccessID* : à partir de la clé d'accès du compartiment, exemple d'ID de clé d'accès : AKIAIOSFODNN7EXAMPLE \* *AccessKey* : à partir de la clé d'accès du compartiment, exemple de clé d'accès secrète : wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

**Conseil** : en remplacement des lignes *AccessID* et *AccessKey*, vous pouvez créer un objet d'autorisation pour masquer en toute sécurité les informations d'identification de la banque d'objets du cloud.

#### Exemple 1

Cet exemple sélectionne toutes les lignes de la valeur locale sample\_data\_local locale pour copier le jeu de données dans la partition *sample1* de la banque d'objets :

    SELECT * FROM WRITE_NOS (
        ON ( SELECT * FROM sample_data_local )
        USING
            LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
            AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
            --if using the authorization object, replace the line above with the line below minus the two dashes in front of the line:
            --AUTHORIZATION (authorization_object_name)        
            STOREDAS ('PARQUET')
    ) AS d;

#### Exemple 2

Cet exemple copie le même jeu de données en le partitionnant selon l'année de date du capteur sous la partition *sample2* :

    SELECT * FROM WRITE_NOS (
        ON ( SELECT
                sensdate
                ,senstime
                ,epoch
                ,moteid
                ,temperature
                ,humidity
                ,light
                ,voltage
                ,sensdatetime
                ,year(sensdate) TheYear
             FROM sample_data_local )
        PARTITION BY TheYear ORDER BY TheYear
        USING
            LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample2/')
            AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
            --if using the authorization object, replace the line above with the line below minus the two dashes in front of the line:
            --AUTHORIZATION (authorization_object_name)              
            NAMING ('DISCRETE')
            INCLUDE_ORDERING ('FALSE')
            STOREDAS ('PARQUET')
     AS d;

### Valider les résultats WRITE\_NOS

Vous pouvez valider les résultats des cas d'utilisation WRITE\_NOS en lisant les données Parquet selon les exemples READ\_NOS disponibles. \#\#\# Nettoyer

Supprimer les objets créés dans votre propre schéma de base de données :

    DROP AUTHORIZATION InvAuth;
    DROP TABLE sample_data;
    DROP TABLE sample_data_local;
