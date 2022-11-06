-   [Consultar datos en el almacenamiento de objetos en la nube](#query-data-on-cloud-object-storage)
-   [Escribir datos en un almacén de objetos en la nube](#write-data-to-a-cloud-object-store)

Consultar datos en el almacenamiento de objetos en la nube
----------------------------------------------------------

### Introducción

Los siguientes ejemplos demuestran cómo acceder a los datos que se encuentran en almacenes de objetos en la nube. Puedes copiar y modificar las consultas de ejemplo que aparecen a continuación para acceder a tus propios conjuntos de datos. Para simplificar el proceso, los conjuntos de datos de ejemplo se proporcionan a través de un bucket de acceso público que no requiere configuración ni credenciales.

Para utilizar SQL para acceder a tu propio almacén de objetos en la nube, sustituye lo siguiente: \* **LOCATION**: sustitúyelo con la ubicación de tu almacén de objetos. La ubicación debe comenzar con /s3/ (Amazon) o /az/ (Azure). \* **AUTHORIZATION**: sustituye las credenciales **USER** y **PASSWORD** vacías con tu **ACCESS\_KEY\_ID** y **SECRET\_ACCESS-KEY**.

**Nota**: el parámetro AUTHORIZATION solo es necesario si no se utilizan roles y políticas IAM para gestionar la seguridad.

Lectura de datos de almacenamiento de objetos en la nube
--------------------------------------------------------

Los formatos de archivo Parquet, CSV y JSON son compatibles con la lectura del almacenamiento de objetos en la nube. Puedes leer datos de un almacenamiento de objetos en la nube utilizando READ\_NOS o tablas externas.

#### READ\_NOS

READ\_NOS te permite hacer lo siguiente sin necesidad de realizar cambios en la base de datos: \* Realizar una consulta ad hoc sobre los datos almacenados en un almacén de objetos en la nube. \* Examinar el esquema de los archivos de datos.

#### Tablas externas

El privilegio CREATE TABLE te permite crear una tabla externa dentro de la base de datos, lo que proporciona una experiencia similar a la de trabajar con tablas relacionales locales. Utilizando una tabla externa, puedes hacer lo siguiente: \* Cargar datos externos en la base de datos. \* Unir datos externos a datos almacenados en la base de datos. \* Filtrar los datos. \* Utilizar vistas para simplificar la forma en que se muestran los datos a los usuarios.

Los datos leídos mediante el almacén de objetos nativo nunca son persistentes.

Los datos se pueden cargar en la base de datos usando las instrucciones INSERT SELECT y CREATE TABLE AS ... WITH DATA.

### Configurar credenciales seguras mediante un objeto de autorización

Crear un objeto de autorización te permite almacenar las credenciales de tu almacén de objetos en la nube (y hacer referencia a ellas) en Vantage de forma segura. Ten en cuenta que nuestros conjuntos de datos de muestra se proporcionan a través de un bucket de acceso público para el que no se requieren credenciales.

    CREATE AUTHORIZATION InvAuth
    USER ''
    PASSWORD '';

### Leer datos almacenados en Amazon S3 utilizando READ\_NOS

Seleccionar los datos del almacén de objetos en la nube utilizando READ\_NOS:

    SELECT TOP 2 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    ) AS D;

### Examinar el esquema de los datos almacenados en Amazon S3 utilizando READ\_NOS

Seleccionar solo el esquema de los datos del almacén de objetos en la nube utilizando READ\_NOS:

    SELECT TOP 1 * FROM (
    LOCATION='/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/'
    AUTHORIZATION=InvAuth
    RETURNTYPE='NOSREAD_SCHEMA'
    ) AS d;

### Leer datos almacenados en Amazon S3 utilizando CREATE FOREIGN TABLE

Crear una tabla externa:

    CREATE FOREIGN TABLE sample_data
    ,EXTERNAL SECURITY InvAuth
    USING ( LOCATION('/s3/s3.amazonaws.com/trial-datasets/IndoorSensor/') );

Seleccionar los datos utilizando la tabla externa:

    SELECT TOP 2 * FROM sample_data;

### Importar datos a Vantage desde datos almacenados en Amazon S3

Para que persistan los datos de un almacén de objetos en la nube, utiliza una instrucción CREATE TABLE AS:

    CREATE TABLE AS sample_data_local ( SELECT * FROM sample_data ) WITH DATA;

Escribir datos en un almacén de objetos en la nube
--------------------------------------------------

### Introducción

Los siguientes ejemplos demuestran cómo copiar datos desde Vantage a un almacén de objetos en la nube. Debes indicar tu propio bucket para ejecutar las consultas de ejemplo.

### WRITE\_NOS

Con WRITE\_NOS puedes hacer lo siguiente: \* Copiar/escribir datos directamente en un almacén de objetos en la nube. \* Convertir los datos en formato Parquet sin comprimir, a menos que el usuario especifique la compresión Snappy. \* Especificar una o más columnas de la tabla de origen como atributos de partición en el almacén de objetos en la nube de destino. \* Crear y actualizar un archivo de manifiesto con todos los objetos creados durante el proceso de copia.

Antes de ejecutar los ejemplos, sustituye los siguientes campos en las secuencias de comandos de ejemplo: \* *YourBucketName*: sustitúyelo con el nombre de tu bucket. \* *AccessID*: de la clave de acceso de tu bucket. - Ejemplo de ID de clave de acceso: AKIAIOSFODNN7EXAMPLE \* *AccessKey*: de la clave de acceso a tu bucket. - Ejemplo de clave de acceso secreta: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

**Consejo**: como alternativa a las líneas *AccessID* y *AccessKey*, puedes crear un objeto de autorización para ocultar de forma segura las credenciales de tu almacén de objetos en la nube.

#### Ejemplo 1

Este ejemplo selecciona todas las filas del archivo local sample\_data\_local para copiar el conjunto de datos en la partición *sample1* del almacén de objetos:

    SELECT * FROM WRITE_NOS (
        ON ( SELECT * FROM sample_data_local )
        USING
            LOCATION ('/s3/YourBucketName.s3.amazonaws.com/sample1/')
            AUTHORIZATION ('{\"Access_ID\":\"AccessID\",\"Access_Key\":\"AccessKey\"}')
            --if using the authorization object, replace the line above with the line below minus the two dashes in front of the line:
            --AUTHORIZATION (authorization_object_name)        
            STOREDAS ('PARQUET')
    ) AS d;

#### Ejemplo 2

Este ejemplo copia el mismo conjunto de datos partiendo por el año de la fecha del sensor en la partición *sample2*:

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

### Validar los resultados de WRITE\_NOS

Puedes validar los resultados de tus casos de uso de WRITE\_NOS mediante la lectura de los datos de Parquet como se describe en los ejemplos de READ\_NOS.\#\#\# Limpiar

Soltar los objetos creados en tu propio esquema de base de datos:

    DROP AUTHORIZATION InvAuth;
    DROP TABLE sample_data;
    DROP TABLE sample_data_local;
