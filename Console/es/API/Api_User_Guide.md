API GraphQL de Management Console
=================================

Índice
------

-   [Introducción](#Getting-Started)
-   [Información general](#Información%20general)
-   [Acerca de GraphQL](#About-Graphql)
-   [El extremo de la API GraphQL](#The-GraphQL-API-Endpoint)
-   [Llamando a la API GraphQL](#Calling-the-GraphQL-API)
    -   [Autenticación](#Autenticación)
    -   [Cuerpo de la solicitud](#Request-Body)
    -   [Llamada a la API de ejemplo](#Example-API-Call)
-   [Consultas y mutaciones admitidas](#Supported-Queries-and-Mutations)
    -   [Consultas](#Consultas)
    -   [Mutaciones](#Mutaciones)
-   [Manejo de errores](#Error-Handling)
-   [Bibliotecas cliente de GraphQL](#GraphQL-Client-Libraries)

Introducción
------------

Esta sección repasa varios tutoriales prácticos que se pueden seguir para empezar a trabajar rápidamente. Además, incluye ejemplos de trabajo con las API públicas de Management Console.

-   [Tutorial de Postman](./appendix/postman/tutorial.md)
-   [Tutorial de NodeJS](./appendix/nodejs/tutorial.md)
-   [Tutorial de Python](./appendix/python/tutorial.md)

Información general
-------------------

La API Vantage Console (VC) para VantageCloud Enterprise brinda acceso programático a operaciones comunes de elasticidad de bases de datos. Con la disponibilidad de la nueva API, los usuarios autorizados de VantageCloud Enterprise ahora pueden crear secuencias de comandos/aplicaciones personalizadas (clientes) para administrar directamente sus sistemas Teradata. Por ejemplo, un administrador puede usar la API pública VC para administrar los costes iniciando o deteniendo el motor SQL de un sitio teniendo en cuenta los requisitos de uso.

Acerca de GraphQL
-----------------

GraphQL es un lenguaje de consultas para API que:

-   Describe capacidades de la API con un sólido [Esquema escrito](https://graphql.org/learn/schema/)
    -   Descubra las capacidades que admite la API a través de un esquema escrito que describe todos los puntos de entrada (consultas/mutaciones) y el esquema de los datos devueltos
    -   El esquema de GraphQL se establece a través del lenguaje de definición de esquemas (SDL) de GraphQL.
-   Permite a los clientes solicitar lo que necesitan a través de [Consultas y mutaciones](https://graphql.org/learn/queries/)
    -   Las llamadas a la API GraphQL devuelven exactamente lo que se solicitó (ni más ni menos)
    -   Los clientes controlan los datos que requieren

La especificación oficial de GraphQL se encuentra [aquí](https://graphql.github.io/graphql-spec/June2018/).

El extremo de la API GraphQL
----------------------------

-   Autenticación con credenciales de usuario de Teradata Vantage.
-   El extremo de la API pública VC de GraphQL es: `https://api.cloud.vantage.teradata.com/graphql/`
-   El esquema de definición de lenguaje (SDL) de GraphQL se puede descargar en: `https://api.cloud.vantage.teradata.com/graphql/sdl`
    -   El SDL se puede importar a su cliente para crear consultas/mutaciones personalizadas

Llamando a la API GraphQL
-------------------------

La API GraphQL es un extremo HTTP, similar a una API REST. La diferencia está en el contenido de la solicitud (especificación de GraphQL - SDL) frente a la ruta de extremo de la API REST, sus encabezados y el cuerpo de la solicitud. Todas las llamadas al extremo de GraphQL (consultas o mutaciones) utilizarán el `POST` método HTTP.

### Autenticación

La API GraphQL de VC se protege con autenticación básica (consulte [RFC 7617](https://tools.ietf.org/html/rfc7617)). Para realizar llamadas a esta API (cualquier consulta o mutación de GraphQL), se requerirá el siguiente `Authorization` encabezado:

``` sourceCode
{
...
"Authorization": "Basic <base64 encoded username:password>"
...
}
```

### Cuerpo de la solicitud

Formato de cuerpo de la solicitud

``` sourceCode
{
  "operationName":"myOperationName",
  "query":"query myOperationName {...}"
}
```

### Llamada a la API de ejemplo con cURL

A continuación se puede ver un ejemplo de llamada de detención del motor SQL (mutación) con cURL. Se pueden encontrar tutoriales y ejemplos adicionales en la sección [Introducción](#Getting-Started) anterior.

``` sourceCode
curl 'https://api.cloud.vantage.teradata.com/graphql' -H 'authorization: Basic <base64 encoded username:password>' -H 'content-type: application/json' --data-binary '{"operationName":"stopSqlEngine","variables":{},"query":"mutation stopSqlEngine { stopSqlEngine(siteId: \"TDICA01780PRD00\") {id, name, status, startTime, endTime, details }}"}'
```

Consultas y mutaciones admitidas (lista incompleta)
---------------------------------------------------

### Consultas

<table style="width:99%;">
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th>Consulta</th>
<th>Entradas</th>
<th>Detalles</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>API de sitio generales</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>api</td>
<td>n/a</td>
<td>Detalles de versión de API</td>
</tr>
<tr class="odd">
<td>user</td>
<td>n/a</td>
<td>Obtener los roles del usuario en políticas</td>
</tr>
<tr class="even">
<td>sites</td>
<td>n/a</td>
<td>Enumerar sus sitios de Teradata</td>
</tr>
<tr class="odd">
<td>site</td>
<td>id (ID de sitio)</td>
<td>Obtener detalles de un sitio específico</td>
</tr>
<tr class="even">
<td>sqlEngine</td>
<td>siteId</td>
<td>Obtener detalles de un motor SQL específico para un ID de sitio dado</td>
</tr>
<tr class="odd">
<td>getSqlEngineOperation</td>
<td>siteId, operationId</td>
<td>Obtener detalles de una operación específica del motor SQL</td>
</tr>
<tr class="even">
<td>mlEngine</td>
<td>siteId</td>
<td>Obtener detalles de un motor ML específico para un ID de sitio dado</td>
</tr>
<tr class="odd">
<td>getMlEngineOperation</td>
<td>siteId, operationId</td>
<td>Obtener detalles de una operación específica del motor ML</td>
</tr>
<tr class="even">
<td>privateLink</td>
<td>siteId</td>
<td>Obtener información de enlace privado sobre un sitio</td>
</tr>
<tr class="odd">
<td><strong>API del sistema</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSystemUsage</td>
<td>usageQuery(siteId, startTime, endTime, namespace, dataPoints)</td>
<td>Obtener los datos de utilización de un sitio</td>
</tr>
<tr class="odd">
<td>getNotifications</td>
<td>lastSeenNotificationTimestamp, lastEvaluatedKey(notificationId, userId, receivedTimestamp)</td>
<td>Obtener notificaciones globales para un usuario</td>
</tr>
<tr class="even">
<td>getNotificationSettings</td>
<td>receivedTimestamp</td>
<td>Obtener ajustes para notificaciones de correo electrónico globales para un usuario</td>
</tr>
<tr class="odd">
<td>getAlerts</td>
<td>alertParams ( site_id, activity_type, engine_types, dept_id )</td>
<td>Obtener todas las alarmas de umbral de este usuario o una lista filtrada de ellas</td>
</tr>
<tr class="even">
<td>sandboxes</td>
<td></td>
<td>Obtener todos los espacios aislados de este usuario</td>
</tr>
<tr class="odd">
<td>sandbox</td>
<td>sandboxId</td>
<td>Obtener información sobre un espacio aislado</td>
</tr>
<tr class="even">
<td><strong>Monitorización de consumo</strong></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>getVantageUnits</td>
<td>aggregatesQuery</td>
<td>Obtener datos de uso de la unidad Vantage para los sitios habilitados para Monitorización de consumo de Vantage</td>
</tr>
<tr class="even">
<td>getCDSUsage</td>
<td>aggregatesQuery</td>
<td>Obtener datos de almacenamiento de datos consumidos de los sitios habilitados para Monitorización de consumo de Vantage</td>
</tr>
<tr class="odd">
<td>getQueryActivity</td>
<td>aggregatesQuery</td>
<td>Obtener datos de actividad y uso de consultas de Vantage para los sitios habilitados para Monitorización de consumo de Vantage</td>
</tr>
<tr class="even">
<td>getWeeklyStats</td>
<td>aggregatesQuery</td>
<td>Obtener datos de consulta para los sitios habilitados para Monitorización de consumo de Vantage</td>
</tr>
<tr class="odd">
<td>getTokenUnits</td>
<td>aggregatesQuery</td>
<td>Obtener datos de consumo de unidad para los sitios habilitados para Monitorización de consumo de Vantage</td>
</tr>
<tr class="even">
<td>getTokenStorage</td>
<td>aggregatesQuery</td>
<td>Obtener datos de almacenamiento de consumo de unidad para los sitios habilitados para Monitorización de consumo de Vantage</td>
</tr>
<tr class="odd">
<td><em>aggregatesQuery (interval_type, activity_type (STORAGE, UNITS, VANTAGE_UNITS, CDS), site_id, engine_types, range_begin, range_end, grouping, dept_id)</em></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getForecast</td>
<td>siteId, numOfDays</td>
<td>Obtener datos de uso previsto de la unidad Vantage para los sitios habilitados para Monitorización de consumo de Vantage</td>
</tr>
<tr class="odd">
<td>getContracts</td>
<td>siteId</td>
<td>Obtener datos de contrato para los sitios habilitados para Monitorización de consumo de Vantage</td>
</tr>
<tr class="even">
<td>getTokenContracts</td>
<td>siteId</td>
<td>Obtener datos de contrato para los sitios habilitados para Monitorización de consumo de unidad</td>
</tr>
<tr class="odd">
<td><strong>Trabajo de protección de datos, copia de seguridad y restauración</strong>s</td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSiteDataProtectionPlans</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Obtener todos los planes de protección de este sitio</td>
</tr>
<tr class="odd">
<td>getCustomerDataProtectionPlans</td>
<td>page (number), pageSize (number)</td>
<td>Obtener todos los planes de protección de este usuario</td>
</tr>
<tr class="even">
<td>getCustomerExecutionHistory</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Obtener el historial y el estado de todos los trabajos de este usuario (se puede filtrar por ID de sitio)</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanExecutionHistory</td>
<td>siteId, jobId, page (number), pageSize (number)</td>
<td>Obtener el historial y el estado de todas las ejecuciones de un trabajo específico</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanDetails</td>
<td>siteId, jobId, includeSettings (boolean)</td>
<td>Obtener todos los detalles de un trabajo de protección de datos específico</td>
</tr>
<tr class="odd">
<td>getExecutionById</td>
<td>siteId, jobId, executionId</td>
<td>Obtener detalles de una ejecución de trabajo de protección de datos específica</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanSchedules</td>
<td>siteId, jobId</td>
<td>Obtener una lista de las horas de ejecución programadas para un trabajo de protección de datos</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanScheduleDetails</td>
<td>siteId, jobId, scheduleId</td>
<td>Obtener detalles específicos para una ejecución programada de un trabajo de protección de datos</td>
</tr>
<tr class="even">
<td>getNextRuns</td>
<td>siteId, jobId, limit (number)</td>
<td>Obtener una lista de las próximas ejecuciones programadas de trabajos de protección de datos</td>
</tr>
<tr class="odd">
<td>getRetainedCopiesForDataProtectionPlan</td>
<td>siteId, jobId, page? (number), pageSize? (number)</td>
<td>Obtener una lista de copias de seguridad correctas almacenadas que se han creado a partir de un trabajo de protección de datos</td>
</tr>
<tr class="even">
<td>getRetainedCopiesForSite</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Obtener una lista de copias de seguridad correctas almacenadas que se han creado para todos los trabajos de protección de datos en un sitio en concreto</td>
</tr>
<tr class="odd">
<td>getRetainedCopies</td>
<td>page (number), pageSize (number)</td>
<td>Obtener una lista de copias de seguridad correctas almacenadas que se han creado para este usuario</td>
</tr>
<tr class="even">
<td>getSiteDatabases</td>
<td>siteId</td>
<td>Cargar la lista de bases de datos en el sitio para restaurar a una base de datos diferente</td>
</tr>
<tr class="odd">
<td>getDatabaseObjects</td>
<td>siteId, xAuthCredential, objectName, objectType, search, page (number), pageSize (number)</td>
<td>Obtener una lista de objetos existentes en la base de datos para elegir de cuál hacer la copia de seguridad</td>
</tr>
<tr class="even">
<td>restoreAuthenticationCheck</td>
<td>siteId</td>
<td>Comprobar si el usuario tiene las credenciales de autenticación adecuadas para realizar una restauración en los objetos seleccionados</td>
</tr>
<tr class="odd">
<td>getDRDetails</td>
<td>siteId, actionType(getTargets, getDRDetails)</td>
<td>Obtener los detalles de intento de recuperación ante desastres con instantánea de un sitio</td>
</tr>
<tr class="even">
<td>getFailoverDetails</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Obtener detalles de conmutación por error de recuperación ante desastres con instantánea de un sitio</td>
</tr>
<tr class="odd">
<td>getBackupJobObjects</td>
<td>siteId, jobId, executionId</td>
<td>Obtener los objetos guardados destinados a una copia de seguridad de DSA específica</td>
</tr>
<tr class="even">
<td>getRestoreHistory</td>
<td>siteId, backupJobId</td>
<td>Obtener el historial de todas las copias de seguridad de DSA para un usuario, específicas de un sitio o para un trabajo de copia de seguridad determinado</td>
</tr>
<tr class="odd">
<td>getRestoreExecutions</td>
<td>siteId, jobId, executionId, restoreJobId</td>
<td>Obtener una lista de intentos de ejecución para un trabajo o una ejecución de copia de seguridad específicos</td>
</tr>
<tr class="even">
<td>getRestoreExecutionDetails</td>
<td>siteId, jobId, executionId, restoreExecutionId</td>
<td>Obtener los detalles de un intento de ejecución de una restauración de DSA</td>
</tr>
</tbody>
</table>

### Mutaciones

<table style="width:99%;">
<colgroup>
<col style="width: 25%" />
<col style="width: 37%" />
<col style="width: 37%" />
</colgroup>
<thead>
<tr class="header">
<th>Mutation</th>
<th>Entradas</th>
<th>Detalles</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>API de sitio generales</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>startSqlEngine</td>
<td>siteId (ID de sitio para motor SQL)</td>
<td>Iniciar motor SQL para el ID de sitio dado</td>
</tr>
<tr class="odd">
<td>stopSqlEngine</td>
<td>siteId (ID de sitio para motor SQL)</td>
<td>Detener el motor SQL en un ID de sitio específico</td>
</tr>
<tr class="even">
<td>scaleOutInSqlEngine</td>
<td>siteId (ID de sitio para motor SQL), nodeCount (número de nodos para ampliar/reducir)</td>
<td>Ampliar o reducir el motor SQL para proporcionar el recuento de nodos del ID de sitio dado</td>
</tr>
<tr class="odd">
<td>scaleUpDownSqlEngine</td>
<td>siteId (ID de sitio para motor SQL), instanceType (tipo de instancia de nodo al que cambiar)</td>
<td>Ampliar o reducir el motor SQL al tipo de instancia proporcionado para el ID de sitio dado</td>
</tr>
<tr class="even">
<td>storageResizeSqlEngine</td>
<td>siteId (ID de sitio para motor SQL), value (valor de nuevo tamaño de almacenamiento), units (unidades del tamaño del almacenamiento)</td>
<td>Redimensionamiento del almacenamiento para el motor SQL al valor total indicado en las unidades</td>
</tr>
<tr class="odd">
<td>startMlEngine</td>
<td>siteId (ID de sitio para motor ML)</td>
<td>Iniciar motor ML para el ID de sitio dado</td>
</tr>
<tr class="even">
<td>stopMlEngine</td>
<td>siteId (ID de sitio para motor ML)</td>
<td>Detener el motor ML en un ID de sitio específico</td>
</tr>
<tr class="odd">
<td>addPrivateLinkUsers</td>
<td>id, siteId, users (lista de usuarios)</td>
<td>Agregar usuarios de enlace privado a la lista de permitidos para conexiones de enlace privado</td>
</tr>
<tr class="even">
<td>removePrivateLinkUsers</td>
<td>id, siteId, users(list of users)</td>
<td>Quitar usuarios de enlace privado de la lista de permitidos para conexiones de enlace privado</td>
</tr>
<tr class="odd">
<td><strong>API del sistema</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>assumeRole</td>
<td>targetRole (ROLE)</td>
<td>Cambiar/Asumir el rol de su usuario</td>
</tr>
<tr class="odd">
<td>createAlert</td>
<td>alert ()</td>
<td>Crear una alarma de umbral</td>
</tr>
<tr class="even">
<td>updateAlert</td>
<td>alertId, alert ()</td>
<td>Actualizar alarma de umbral</td>
</tr>
<tr class="odd">
<td>deleteAlerts</td>
<td>alertIds</td>
<td>Eliminar múltiples alarmas por lista de ID</td>
</tr>
<tr class="even">
<td>toggleGlobalNotification</td>
<td>updatedSubscription(email, topicName, channelName)</td>
<td>Suscribir al usuario a un tema de notificaciones</td>
</tr>
<tr class="odd">
<td>createSandbox</td>
<td>name, parentSiteId (siteId)</td>
<td>Crear una copia de espacio aislado de un sitio</td>
</tr>
<tr class="even">
<td>deleteSandbox</td>
<td>sandboxId</td>
<td>Solicitar que se elimine un espacio aislado</td>
</tr>
<tr class="odd">
<td><strong>Trabajos de protección de datos, copia de seguridad y restauración</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>createDataProtectionPlan</td>
<td>siteId, createInput (name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism (DSA, CDP,</td>
<td>DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects(objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName, objectType,))</td>
</tr>
<tr class="odd">
<td>targetRetentionCopiesCount (number), backupType(FULL, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Obtener un plan de protección de un sitio</td>
<td></td>
</tr>
<tr class="even">
<td>updateDataProtectionSettings</td>
<td>siteId, jobId, updateInput (name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism</td>
<td>(DSA, CDP, DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects(objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName, objectType))</td>
</tr>
<tr class="odd">
<td>targetRetentionCopiesCount (number), backupType(FULL, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Actualizar un plan de protección de datos de un sitio</td>
<td></td>
</tr>
<tr class="even">
<td>deleteDataProtectionPlan</td>
<td>siteId, jobId</td>
<td>Eliminar plan de protección de datos</td>
</tr>
<tr class="odd">
<td>createDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Crear un programa para un plan de protección de datos</td>
</tr>
<tr class="even">
<td>updateDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Actualizar un programa para un plan de protección de datos</td>
</tr>
<tr class="odd">
<td>deleteDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleId</td>
<td>Eliminar una programación de un plan de protección de datos</td>
</tr>
<tr class="even">
<td>previewDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Obtener una vista previa de una programación de un plan de protección de datos</td>
</tr>
<tr class="odd">
<td>abortJob</td>
<td>siteId, jobId</td>
<td>Interrumpir un plan de protección de datos</td>
</tr>
<tr class="even">
<td>instantJobRun</td>
<td>siteId, jobId, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR)</td>
<td>Ejecutar un plan de protección de datos ahora mismo</td>
</tr>
<tr class="odd">
<td>restoreData</td>
<td>siteId, executionId, jobId, settings (name, abortOnAccessRightsViolation (boolean), runAsCopyJob (boolean), restoreToDifferentDb (boolean), renameRestoredObjects (boolean),</td>
<td>skipStatistics (boolean), skipJoinHashIndexes (boolean), targetDatabase, tableNameSuffix, objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName,</td>
</tr>
<tr class="even">
<td>updateRestoreJobSettings</td>
<td>siteId, jobId, backupExecutionId, updateInput(name, abortOnAccessRightsViolation (boolean), runAsCopyJob (boolean), restoreToDifferentDb (boolean), renameRestoredObjects</td>
<td>(boolean), skipStatistics (boolean), skipJoinHashIndexes (boolean), targetDatabase, tableNameSuffix, objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects</td>
</tr>
<tr class="odd">
<td>failOverData</td>
<td>siteId, executionId, jobId, failOverInput ( name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism</td>
<td>(DSA, CDP, DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects</td>
</tr>
<tr class="even">
<td>precheckRestore</td>
<td>siteId, executionId, jobId</td>
<td>Validar una instantánea (en el sitio dado, si se proporciona) para que esté disponible para su uso como copia de restauración</td>
</tr>
<tr class="odd">
<td>protectRetainCopy</td>
<td>siteId, jobId, backupSetId, isRetained (boolean)</td>
<td>Proteger o quitar protección de una copia retenida</td>
</tr>
</tbody>
</table>

Manejo de errores
-----------------

Al igual que las API REST, las llamadas a las API GraphQL también pueden devolver respuestas de error. Algunos ejemplos son los errores por no autorización/prohibición, recurso no encontrado, operación fallida, etc. Los detalles del error de una llamada a la API GraphQL se encuentran en el cuerpo de la respuesta devuelta.

Dado que una llamada a GraphQL puede abarcar varios servicios, los objetos de error se devuelven en forma de lista en la parte `errors` del cuerpo de la respuesta. La estructura de un objeto de error es la que se describe a continuación:

``` sourceCode
"error": {
  "message" # message string
  "extensions": {  # additional metadata about the error
    "code" # error code, e.g. UNAUTHORIZED, FORBIDDEN, BAD_USER_INPUT, etc.
    ... # other error related details
  },
  "path": [String] # Query path(s) that resulted in this error
  "locations": ["line": Int, "column": Int] # Query line(s) and column(s) that resulted in this error
}
```

El código de error se encuentra en la parte `extensions` del objeto de error en un campo llamado `code`.

### Ejemplo de respuesta No autorizada

La respuesta a una llamada a la API no autorizada.

``` sourceCode
{
  "errors": [
    {
      "message": "unauthorized",
      "extensions": {
        "code": "UNAUTHORIZED"
      }
    }
  ]
}
```

### Ejemplo de respuesta Solicitud no encontrada

Al intentar obtener los detalles de un sitio que no existe.

``` sourceCode
{
  "errors": [
    {
      "message": "Site for the provided ID 'NOT_EXISTENT_SITE_ID' was not found",
      "locations": [
        {
          "line": 2,
          "column": 3
        }
      ],
      "path": [
        "stopSqlEngine"
      ],
      "extensions": {
        "id": "NOT_EXISTENT_SITE_ID",
        "status": "NOT_FOUND",
        "code": "BAD_USER_INPUT"
      }
    }
  ],
  "data": {
    "stopSqlEngine": null
  }
}
```

### Ejemplo de respuesta Solicitud no válida

Al llamar a una operación de inicio del motor SQL en un sitio donde esa operación no está disponible en ese momento (por ejemplo, porque el motor SQL ya se está ejecutando).

``` sourceCode
{
  "errors": [
    {
      "message": "SQL Engine START Operation Failed",
      "locations": [
        {
          "line": 2,
          "column": 3
        }
      ],
      "path": [
        "startSqlEngine"
      ],
      "extensions": {
        "status": "OPERATION_NOT_AVAILABLE",
        "availableOperations": [
          "SCALE_UP_SCALE_DOWN",
          "SCALE_OUT_SCALE_IN",
          "STOP",
          "STORAGE_RESIZE"
        ],
        "details": "SQL Engine START Operation is not available at this time.",
        "code": "BAD_USER_INPUT"
      }
    }
  ],
  "data": {
    "startSqlEngine": null
  }
}
```

Bibliotecas cliente de GraphQL
------------------------------

La siguiente lista contiene bibliotecas de cliente populares para llamar a las API GraphQL:

[Clientes de GraphQL](https://graphql.org/code/#graphql-clients)
