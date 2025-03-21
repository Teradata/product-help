### Almacenamiento de datos en el sistema de archivos de objetos de VantageCloud Lake Edition

### Antes de empezar

Abra el editor para continuar con este caso de uso. [INICIAR EDITOR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introducción

A continuación se presenta un resumen de cómo almacenar datos en el sistema de archivos de objetos (OFS) de VantageCloud Lake Edition.

### Configuración

Cree una tabla externa con datos en el depósito S3.

``` sourceCode
REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
CREATE FOREIGN TABLE foreign_csvdata
,EXTERNAL SECURITY DefaultAuth
USING (location('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/CSVDATA/'));
```

Verifique los datos en la tabla externa.

``` sourceCode
SELECT * FROM foreign_csvdata;
```

### Escenario 1

Si tiene una tabla externa existente con datos en el depósito S3 y desea cargar los datos en una nueva tabla OFS, puede usar la siguiente declaración.

``` sourceCode
CREATE MULTISET TABLE ofs_csvdata
,STORAGE = TD_OFSSTORAGE
AS ( SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata )
WITH DATA;
```

Compruebe los datos en la nueva tabla OFS.

``` sourceCode
SELECT * FROM ofs_csvdata;
```

Elimine la tabla OFS.

``` sourceCode
DROP TABLE ofs_csvdata;
```

### Escenario 2

Si tiene una tabla OFS de Sistema de archivos de Lake existente y desea cargar datos de otra tabla en ella, puede usar la siguiente declaración.

Cree una nueva tabla OFS.

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

Cargue datos de una tabla externa en la tabla OFS.

``` sourceCode
INSERT INTO ofs_csvdata SELECT site_no, datetime, Precipitation, GageHeight, Flow, GageHeight2 FROM foreign_csvdata;
```

Verifique los datos en la tabla OFS.

``` sourceCode
SELECT * FROM ofs_csvdata;
```

Elimine las tablas.

``` sourceCode
DROP TABLE ofs_csvdata;
DROP TABLE foreign_csvdata;
```

### Escenario 3

Si desea cargar datos de un almacén de objetos en una nueva tabla OFS por primera vez, puede utilizar la siguiente declaración.

Para utilizar esta opción, necesitará el permiso EXECUTE en TD\_SYSFNLIB.READ\_NOS. Puede obtenerlo con la siguiente declaración: comuníquese con el administrador de su base de datos para obtener el permiso.

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

Compruebe los datos en la nueva tabla OFS

``` sourceCode
SELECT * FROM ofs_csvdata;
```

Elimine las tablas.

``` sourceCode
DROP TABLE ofs_csvdata;
```
