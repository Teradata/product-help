Conjunto de datos de TelcoChurn
===============================

El conjunto de datos TelcoChurn se utiliza en casos de uso de telecomunicaciones.

Para actualizar los datos en S3

    aws s3 rm s3://${S3_BUCKET}/TelcoChurn --recursive   

    aws s3 cp data/* s3://${S3_BUCKET}/TelcoChurn/ 

Debido a que estamos usando una autorización, esto no es necesario, pero si quisiéramos que los archivos sean accesibles públicamente, agregaríamos esto a la llamada cp de s3.

    --acl public-read    

Los archivos SQL en la carpeta de scripts son idempotentes, lo que significa que no importa cuántas veces los ejecute, deben poder volver a ejecutarse y el estado de las tablas será el mismo después de cada ejecución. Para lograr esto, eliminamos los objetos y los volvemos a crear en cada ejecución. Cuando se ejecuta la consulta para eliminar el objeto, ignoramos cualquier error que indique que el objeto no existe, pero debemos manejar los errores en los que el usuario no tiene los permisos correctos.
