### Stockage des données dans le système de fichiers d'objets pour l'édition VantageCloud Lake

### Avant de commencer

Ouvrez l'éditeur pour poursuivre ce cas d'utilisation. [LANCER L'ÉDITEUR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introduction

Voici un résumé du stockage des données dans le système de fichiers d'objets pour l'édition VantageCloud Lake.

### Configuration

Créez une table étrangère avec des données dans un compartiment S3.

``` sourceCode
REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
CREATE FOREIGN TABLE foreign_csvdata
,EXTERNAL SECURITY DefaultAuth
USING (location('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'));
```

Vérifiez les données dans la table étrangère.

``` sourceCode
SELECT * FROM foreign_csvdata;
```

### Scénario 1

Si vous disposez d'une table étrangère existante avec des données dans un compartiment S3 et que vous souhaitez charger celles-ci dans une nouvelle table OFS, vous pouvez utiliser l'instruction suivante.

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata )
WITH DATA;
```

Vérifiez les données dans la nouvelle table OFS.

``` sourceCode
SELECT * FROM ofs_csvdata;
```

Supprimez la table OFS.

``` sourceCode
DROP TABLE ofs_csvdata;
```

### Scénario 2

Si vous disposez d'une table OFS du système de fichiers Lake existante et que vous souhaitez y charger des données d'une autre table, vous pouvez utiliser l'instruction suivante.

Créez une table OFS.

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata,
     STORAGE = TD_OFSSTORAGE
     (
      site_no INTEGER,
      datetime TIMESTAMP(0),
      Precipitation DECIMAL(3,2),
      GageHeight DECIMAL(3,2),
      Flow DECIMAL(3,2),
      GageHeight2 DECIMAL(3,2))
NO PRIMARY INDEX ;
```

Chargez les données de la table étrangère dans la table OFS.

``` sourceCode
INSERT INTO ofs_csvdata SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata;
```

Vérifiez les données dans la table OFS.

``` sourceCode
SELECT * FROM ofs_csvdata;
```

Supprimez les tables.

``` sourceCode
DROP TABLE ofs_csvdata;
DROP TABLE foreign_csvdata;
```

### Scénario 3

Si vous souhaitez charger des données d'une banque d'objets dans une nouvelle table OFS pour la première fois, vous pouvez utiliser l'instruction suivante.

Pour utiliser cette option, vous avez besoin de l'autorisation EXÉCUTER sur TD\_SYSFNLIB.READ\_NOS. Cette autorisation peut être accordée en suivant l'instruction suivante : contactez votre administrateur de base de données pour obtenir l'autorisation.

``` sourceCode
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <username>;
```

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2
FROM (
LOCATION='/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'
AUTHORIZATION=DefaultAuth
) AS d
) WITH DATA;
```

Vérifiez les données dans la nouvelle table OFS

``` sourceCode
SELECT * FROM ofs_csvdata;
```

Supprimez les tables.

``` sourceCode
DROP TABLE ofs_csvdata;
```
