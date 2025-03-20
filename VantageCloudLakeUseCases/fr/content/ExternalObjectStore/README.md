Utilisation de banques d'objets externes : lecture et écriture de données
-------------------------------------------------------------------------

### Avant de commencer

Ouvrez l'éditeur pour poursuivre ce cas d'utilisation. [LANCER L'ÉDITEUR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introduction

Cette section montre comment les utilisateurs peuvent interagir avec les banques d'objets ouverts. Teradata VantageCloud Lake fournit des fonctions natives pour la lecture et l'écriture de données dans ces banques de données évolutives et peu coûteuses, permettant ainsi aux utilisateurs de s'intégrer facilement à de vastes quantités de données stockées dans des instances de Data Lake, ainsi que de décharger des données d'archive ou autres sur ces plateformes.

À des fins d'évaluation, Teradata a fourni des données dans un emplacement de banque d'objets ouverts. Pour les utiliser réellement, les utilisateurs doivent fournir au stockage d'objets des identifiants de connexion ou un autre accès basé sur les rôles. Si vous choisissez d'utiliser votre propre banque d'objets pour interroger les données, remplacez les éléments suivants dans le code SQL :

-   **LOCATION** - Remplacez l'élément par l'emplacement de votre banque d'objets. L'emplacement doit commencer par /s3/ (Amazon), /az/ (Azure) ou /gs/ (Google).
-   **USER** ou **ACCESS\_ID** - Ajoutez le nom d'utilisateur de votre banque d'objets.
-   **PASSWORD** ou **ACCESS\_KEY** - Ajoutez le mot de passe de l'utilisateur sur votre banque d'objets.
-   **SESSION\_TOKEN** - Vous pouvez également ajouter un jeton de session facultatif si vous utilisez AWS Security Token Service pour vous fournir les identifiants d'accès.
-   Supprimez les commentaires pour la clause EXTERNAL SECURITY si nécessaire

Si vous modifiez le code SQL pour accéder à vos propres données dans votre banque d'objets, assurez-vous qu'il est configuré pour autoriser l'accès à partir de l'environnement VantageCloud Lake. Fournissez les identifiants appropriés dans les éléments USER et PASSWORD de l'instruction CREATE AUTHORIZATION ou dans l'argument de chaîne JSON de l'élément AUTHORIZATION utilisé dans l'instruction READ\_NOS.

Pour exécuter ces cas d'utilisation, l'utilisateur doit disposer d'autorisations spécifiques sur les fonctions SQL utilisées pour la lecture et l'écriture dans des banques d'objets externes. Exécutez les instructions suivantes en tant qu'utilisateur de base de données avec des privilèges d'administrateur ou demandez à un administrateur de base de données de les exécuter pour vous.

```sql
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <USERNAME>;
GRANT EXECUTE FUNCTION ON TD_SYSFNLIB.WRITE_NOS TO <USERNAME>; 
```

### Accès au stockage d'objets

Il existe deux manières de lire les données à partir d'une banque d'objets :

#### READ\_NOS

L'opérateur de table READ\_NOS est une fonction qui permet aux utilisateurs d'effectuer les opérations suivantes : \* Exécuter une requête ad hoc sur des données aux formats Parquet, CSV et JSON avec les données en place sur une banque d'objets \* Examiner la structure (disposition) de la banque d'objets \* Examiner le schéma des données formatées

```sql
--This SQL statement will query ten rows of data from the s3 bucket 
--defined in the LOCATION element 
SELECT TOP 10 * FROM ( 
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
  ) AS D; 

--By adding a RETURNTYPE element, and passing either 
-- ‘NOSREAD_KEYS' or ‘NOSREAD_SCHEMA’ arguments 
--users can investigate the objects and structure of the data 
SELECT TOP 10 * FROM (
    LOCATION = '/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
    RETURNTYPE = 'NOSREAD_KEYS' 
  ) AS D; 

SELECT TOP 10 * FROM ( 
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
    RETURNTYPE = 'NOSREAD_SCHEMA'
  ) AS D; 
```

### Lorsque vous accédez à vos propres données

Pour accéder aux banques d'objets externes qui nécessitent une authentification, créez un objet d'autorisation. Cet objet contient les identifiants (nom d'utilisateur, mot de passe, jeton de session, rôle Identity and Access Management \[IAM\], etc.) dont la base de données a besoin pour lire (et/ou écrire) des données. L'instruction suivante peut être utilisée pour créer un objet d'autorisation contenant les identifiants de votre banque d'objets externes. Les identifiants peuvent également être transmis à l'élément AUTHORIZATION de la requête sous forme de chaîne au format JSON.

```sql
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

### Utilisation d'une autorisation pour accéder aux données stockées sur Amazon S3

```sql
SELECT TOP 2 * FROM ( 
LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
AUTHORIZATION='{"ACCESS_ID":"","ACCESS_KEY":""}' 
--AUTHORIZATION='{"access_id":"ACCESS_KEY_ID","access_key":"SECRET_ACCESS_KEY"}'  --[optional AUTHORIZATION using direct credentials] 
--RETURNTYPE='NOSREAD_KEY'  --[optional if wanting to list the layout of the object store] 
--RETURNTYPE='NOSREAD_SCHEMA'  --[optional if wanting to display the schema of the data files]  
) AS D; 
```

#### Tables étrangères

Les tables étrangères permettent à VantageCloud Lake d'accéder aux données du stockage d'objets externes, telles que les données semi-structurées et non structurées dans Amazon S3, Microsoft Azure Blob Storage et Google Cloud Storage. L'intégration de ces données dans la base de données permet aux experts en science des données et aux analystes de données de lire et de traiter ces données avec VantageCloud Lake, à l'aide du code SQL standard. Vous pouvez joindre des données externes à des données relationnelles dans VantageCloud Lake et les traiter à l'aide des analyses et des fonctions intégrées de VantageCloud Lake.

Les données lues par le biais d'une table étrangère ne sont pas conservées et ne peuvent être utilisées que par cette requête.

Les données peuvent être chargées dans la base de données en sélectionnant READ\_NOS ou une table étrangère dans une instruction CREATE TABLE AS … WITH DATA.

### Accès aux données stockées sur Amazon S3 à l'aide de CREATE FOREIGN TABLE

Créez une table étrangère :

```sql
CREATE MULTISET FOREIGN TABLE sample_sensor ,FALLBACK,
     EXTERNAL SECURITY MyAuth
    (
        sensedate DATE,
        sensetime TIME,
        epoch INTEGER,
        moteid INTEGER,
        temperature FLOAT,
        humidity FLOAT,
        light FLOAT,
        voltage FLOAT
    )
USING
    (
        LOCATION  ('/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/')
        MANIFEST  ('FALSE')
        ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
        STOREDAS  ('TEXTFILE')
        HEADER  ('FALSE')
        STRIP_EXTERIOR_SPACES  ('FALSE')
    )
NO PRIMARY INDEX ;
```

Affichez certaines données à l'aide de la table étrangère :

```sql
SELECT TOP 2 * FROM sample_sensor;
```

### Importation de données dans VantageCloud Lake à partir de données stockées sur Amazon S3

Pour conserver les données à partir d'une banque d'objets, nous pouvons utiliser une instruction CREATE TABLE AS comme suit. Intégrez l'instruction READ\_NOS SELECT dans CREATE TABLE AS et assurez-vous d'inclure WITH DATA pour insérer toutes les lignes dans une table locale :

```sql
CREATE MULTISET TABLE sample_local_table AS (
  SELECT * FROM (
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
    AUTHORIZATION=MyAuth
  ) AS D
) WITH DATA;
```

Écriture de données dans une banque d'objets
--------------------------------------------

### Introduction

Voici un résumé de la procédure à suivre pour copier des données de VantageCloud Lake vers une banque d'objets. Vous devez fournir votre propre compartiment et vos propres identifiants (ou objet d'autorisation) pour exécuter les exemples de requêtes ci-dessous.

La requête WRITE\_NOS renvoie la liste des objets et leurs métadonnées écrites dans la banque d'objets cible. Ces résultats sont utiles pour la journalisation ou la traçabilité et d'autres cas d'utilisation administratifs et de gestion.

#### WRITE\_NOS

WRITE\_NOS permet d'effectuer les opérations suivantes : \* Copier ou écrire des données directement dans une banque d'objets \* Compresser éventuellement les données \* Spécifier une ou plusieurs colonnes de la table source comme attributs de partition dans la banque d'objets cible. Les attributs de partition sont utilisés pour générer des clés d'objets supplémentaires lors de l'écriture des données. Ces clés peuvent être utilisées pour organiser et filtrer efficacement des données pour d'autres systèmes lisant les objets. \* Créer et mettre à jour des fichiers manifestes avec tous les objets créés pendant le processus de copie

Avant d'exécuter les exemples suivants, remplacez les champs suivants dans les exemples de scripts : \* *YourBucketName* : Remplacez l'élément par le nom de votre compartiment ou de votre banque d'objets blob auxquels vous disposez d'un accès en écriture. \* Pour que VantageCloud Lake transmette les identifiants appropriés, vous pouvez utiliser un objet d'autorisation ou transmettre les identifiants à l'élément AUTHORIZATION sous forme d'argument au format JSON. \* Remplacez-le par votre objet d'autorisation contenant vos identifiants de stockage, ou : \* *AccessID* : à partir de la clé d'accès de votre compartiment (facultatif) - Exemple d'ID de clé d'accès : AKIAIOSFODNN7EXAMPLE \* *AccessKey* : à partir de la clé d'accès de votre compartiment (facultatif) - Exemple de clé d'accès secrète : wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### Exemple 1

Cet exemple utilise le résultat d'une instruction SELECT qui récupère toutes les lignes de la table **sample\_sensor** (créée ci-dessus) et l'écrit dans la partition ou le conteneur *sample1* du compte ou du compartiment spécifié dans l'élément LOCATION :

```sql
SELECT * FROM WRITE_NOS (
    ON ( SELECT * FROM sample_sensor )
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
        AUTHORIZATION (MyAuth)
--      AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        STOREDAS ('PARQUET')
) AS d;
```

### Exemple 2

Cet exemple utilise la même table **sensor\_data** comme source, cette fois en partitionnant par la date et l'année du capteur sous la partition *sample2* :

```sql
SELECT * FROM WRITE_NOS (
    ON ( SELECT
            sensedate,
            sensetime,
            epoch,
            moteid,
            temperature,
            humidity,
            light,
            voltage,
            year(sensedate) TheYear
        FROM sample_sensor )
    PARTITION BY TheYear ORDER BY TheYear
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample2/')
        AUTHORIZATION (MyAuth)
--      AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        NAMING ('DISCRETE')
        INCLUDE_ORDERING ('FALSE')
        STOREDAS ('PARQUET'))
 AS d;
```

### Valider les résultats de WRITE\_NOS

Vous pouvez valider les résultats de vos cas d'utilisation WRITE\_NOS en créant un objet d'autorisation à l'aide des identifiants de votre utilisateur de compartiment, puis en créant une table étrangère pour accéder aux données au format Parquet comme décrit dans les exemples de la section ci-dessus, ou en exécutant une simple instruction SELECT à l'aide de la syntaxe READ\_NOS ci-dessus.

### Nettoyer

Supprimez les objets que nous avons créés dans notre propre schéma de base de données.

```sql
DROP AUTHORIZATION MyAuth;
```

```sql
DROP TABLE sample_sensor;
```

```sql
DROP TABLE sample_local_table;
```
