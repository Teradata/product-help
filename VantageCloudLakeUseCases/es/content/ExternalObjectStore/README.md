Trabajar con almacenes de objetos externos: lectura y escritura de datos
------------------------------------------------------------------------

### Antes de empezar

Abra el editor para continuar con este caso de uso. [INICIAR EDITOR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introducción

En esta sección se muestra cómo los usuarios pueden interactuar con los almacenes de objetos abiertos. Teradata VantageCloud Lake ofrece funciones nativas para leer y escribir datos en estos almacenes de datos escalables y de bajo coste, lo que permite a los usuarios integrarse fácilmente con grandes cantidades de datos almacenados en Data Lake, así como descargar datos de archivo u otros a estas plataformas.

Con fines de evaluación, Teradata ha proporcionado datos en una ubicación de almacenamiento de objetos abierto. Para el uso en el mundo real, los usuarios deben proporcionar credenciales de inicio de sesión u otro acceso basado en roles al almacenamiento de objetos. Si elige utilizar su propio almacén de objetos para consultar datos, reemplace lo siguiente en el código SQL:

-   **LOCATION**: reemplace con la ubicación del almacén de objetos. La ubicación debe comenzar con /s3/ (Amazon), /az/ (Azure) o /gs/ (Google).
-   **USER** o **ACCESS\_ID**: agregue el nombre de usuario para su almacén de objetos.
-   **PASSWORD** o **ACCESS\_KEY**: agregue la contraseña del usuario en su almacén de objetos.
-   **SESSION\_TOKEN**: también puede agregar un token de sesión opcional si utiliza el Servicio de token de seguridad de AWS para proporcionarle las credenciales de acceso.
-   Elimine el comentario de la cláusula EXTERNAL SECURITY según sea necesario

Si modifica el SQL para acceder a sus propios datos en su almacén de objetos, asegúrese de que esté configurado para permitir el acceso desde el entorno de VantageCloud Lake. Proporcione las credenciales adecuadas en los elementos USER y PASSWORD en la declaración CREATE AUTHORIZATION o en el argumento de cadena JSON del elemento AUTHORIZATION utilizado en la declaración READ\_NOS.

Para llevar a cabo estos casos de uso, el usuario necesita permisos específicos para las funciones de SQL que se utilizan para leer y escribir en almacenes de objetos externos. Ejecute las siguientes instrucciones como un usuario de base de datos con privilegios de administrador o solicite a un administrador de base de datos que las ejecute por usted.

``` sourceCode
GRANT EXECUTE FUNCTION on TD_SYSFNLIB.READ_NOS to <USERNAME>;
GRANT EXECUTE FUNCTION ON TD_SYSFNLIB.WRITE_NOS TO <USERNAME>; 
```

### Acceder al almacenamiento de objetos

Hay dos formas de leer datos de un almacén de objetos:

#### READ\_NOS

El operador de tabla READ\_NOS es una función que permite a los usuarios: \* Realizar una consulta ad hoc sobre datos que están en formatos Parquet, CSV y JSON con los datos locales en un almacén de objetos \* Examinar la estructura (diseño) del almacén de objetos \* Examinar el esquema de los datos formateados

``` sourceCode
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

### Al acceder a sus propios datos

Para acceder a almacenes de objetos externos que requieren autenticación, cree un objeto de autorización. Este objeto contendrá las credenciales (nombre de usuario, contraseña, token de sesión, rol de Identity and Access Management \[IAM\], etc.) que la base de datos necesita para leer (o escribir) datos. La siguiente declaración se puede utilizar para crear un objeto de autorización que contenga las credenciales para su almacén de objetos externo. En su defecto, las credenciales se pueden pasar como una cadena con formato JSON al elemento AUTHORIZATION de la consulta.

``` sourceCode
CREATE AUTHORIZATION MyAuth
USER ''
PASSWORD '';
```

### Uso de una autorización para acceder a los datos almacenados en Amazon S3

``` sourceCode
SELECT TOP 2 * FROM ( 
LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/' 
AUTHORIZATION='{"ACCESS_ID":"","ACCESS_KEY":""}' 
--AUTHORIZATION='{"access_id":"ACCESS_KEY_ID","access_key":"SECRET_ACCESS_KEY"}'  --[optional AUTHORIZATION using direct credentials] 
--RETURNTYPE='NOSREAD_KEY'  --[optional if wanting to list the layout of the object store] 
--RETURNTYPE='NOSREAD_SCHEMA'  --[optional if wanting to display the schema of the data files]  
) AS D; 
```

#### Tablas externas

Las tablas externas permiten que VantageCloud Lake acceda a datos en el almacenamiento de objetos externo, como datos semiestructurados y no estructurados en Amazon S3, Microsoft Azure Blob Storage y Google Cloud Storage. La integración de estos datos en la base de datos permite que los científicos y analistas de datos los lean y procesen con VantageCloud Lake, mediante SQL estándar. Puede unir datos externos a datos relacionales en VantageCloud Lake y procesarlos mediante funciones y análisis integrados de VantageCloud Lake.

Los datos leídos a través de una tabla externa no se conservan y solo los puede utilizar esa consulta.

Los datos se pueden cargar en la base de datos seleccionándolos desde READ\_NOS o una tabla externa en una declaración CREATE TABLE AS… WITH DATA.

### Acceso a los datos almacenados en Amazon S3 con CREATE FOREIGN TABLE

Crear una tabla externa:

``` sourceCode
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

Ver algunos datos utilizando la tabla externa:

``` sourceCode
SELECT TOP 2 * FROM sample_sensor;
```

### Importación de datos a VantageCloud Lake desde datos almacenados en Amazon S3

Para conservar los datos de un almacén de objetos, podemos utilizar una declaración CREATE TABLE AS de la siguiente manera. Incorpore la declaración READ\_NOS SELECT dentro de CREATE TABLE AS y asegúrese de incluir WITH DATA para insertar todas las filas en una tabla local:

``` sourceCode
CREATE MULTISET TABLE sample_local_table AS (
  SELECT * FROM (
    LOCATION='/s3/trial-datasets.s3.amazonaws.com/IndoorSensor/'
    AUTHORIZATION=MyAuth
  ) AS D
) WITH DATA;
```

Escritura de datos en un almacén de objetos
-------------------------------------------

### Introducción

A continuación, se incluye un resumen de cómo copiar datos de VantageCloud Lake a un almacén de objetos. Debe proporcionar su propio depósito y credenciales (u objeto de autorización) para ejecutar las consultas de ejemplo que se muestran a continuación.

La consulta WRITE\_NOS devuelve la lista de objetos y sus metadatos escritos en el almacén de objetos de destino. Estos resultados son útiles para el registro y la trazabilidad, así como para otros casos de uso administrativos y de gestión.

#### WRITE\_NOS

WRITE\_NOS le permite: \* Copiar/escribir datos directamente en un almacén de objetos \* Comprimir los datos de manera opcional \* Especificar una o más columnas en la tabla de origen como atributos de partición en el almacén de objetos de destino. Los atributos de partición se utilizarán para generar claves de objetos adicionales al escribir los datos. Estas claves se pueden utilizar para la organización y el filtrado eficiente de los datos para otros sistemas que lean los objetos. \* Crear y actualizar archivos de manifiesto con todos los objetos creados durante el proceso de copia

Antes de ejecutar los siguientes ejemplos, reemplace los siguientes campos en los scripts de ejemplo: \* *YourBucketName* : Reemplace con el nombre de su depósito o almacén de blobs donde tiene acceso de escritura \* Para que VantageCloud Lake pase las credenciales adecuadas, puede usar un objeto de autorización o pasar las credenciales como un argumento con formato JSON al elemento AUTHORIZATION. \* Reemplace con su objeto de autorización que contiene sus credenciales de almacenamiento, o: \* *AccessID* : de la clave de acceso para su depósito (opcional) - Ejemplo de ID de clave de acceso: AKIAIOSFODNN7EXAMPLE \* *AccessKey* : de la clave de acceso para su depósito (opcional) - Ejemplo de clave de acceso secreta: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

### Ejemplo 1

Este ejemplo utilizará el resultado de una declaración SELECT que recupera todas las filas de la tabla **sample\_sensor** (creada anteriormente) y la escribirá en la partición o contenedor *sample1* en la cuenta o depósito especificado en el elemento LOCATION:

``` sourceCode
SELECT * FROM WRITE_NOS (
    ON ( SELECT * FROM sample_sensor )
    USING
        LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
        AUTHORIZATION (MyAuth)
--      AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
        STOREDAS ('PARQUET')
) AS d;
```

### Ejemplo 2

Este ejemplo utiliza la misma tabla **sensor\_data** como fuente, esta vez particionando por año y fecha del sensor bajo la partición *sample2*:

``` sourceCode
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

### Validar los resultados de WRITE\_NOS

Puede validar los resultados de sus casos de uso de WRITE\_NOS creando un objeto de autorización con sus credenciales de usuario de depósito y luego creando una tabla externa para acceder a los datos de Parquet como se describe en los ejemplos de la sección anterior, o realizando una declaración SELECT simple usando la sintaxis READ\_NOS de arriba.

### Limpiar

Elimine los objetos que hemos creado en nuestro propio esquema de base de datos.

``` sourceCode
DROP AUTHORIZATION MyAuth;
```

``` sourceCode
DROP TABLE sample_sensor;
```

``` sourceCode
DROP TABLE sample_local_table;
```
