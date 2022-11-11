API GraphQL de la console de gestion
====================================

Table des matières
------------------

-   [Mise en route](#Getting-Started)
-   [Présentation](#Présentation)
-   [À propos de GraphQL](#About-Graphql)
-   [Point de terminaison de l'API GraphQL](#The-GraphQL-API-Endpoint)
-   [Appel de l'API GraphQL](#Calling-the-GraphQL-API)
    -   [Authentification](#Authentification)
    -   [Corps de la demande](#Request-Body)
    -   [Exemple d'appel d'API](#Example-API-Call)
-   [Requêtes et mutations prises en charge](#Supported-Queries-and-Mutations)
    -   [Requêtes](#Requêtes)
    -   [Mutations](#Mutations)
-   [Gestion des erreurs](#Error-Handling)
-   [Bibliothèques clientes GraphQL](#GraphQL-Client-Libraries)

Mise en route
-------------

Cette section passe en revue plusieurs didacticiels pratiques que vous pouvez suivre pour une mise en route rapide avec des exemples concrets d'API publiques de la console de gestion.

-   [Didacticiel de Postman](./appendix/postman/tutorial.md)
-   [Didacticiel de NodeJS](./appendix/nodejs/tutorial.md)
-   [Didacticiel de Python](./appendix/python/tutorial.md)

Présentation
------------

L'API Vantage Console (VC) de VantageCloud Enterprise permet un accès par programme aux opérations courantes d'élasticité des bases de données. En disposant de la nouvelle API, les utilisateurs autorisés de VantageCloud peuvent désormais créer des scripts/applications (clients) personnalisés pour gérer directement leurs systèmes Teradata. Par exemple, un administrateur peut utiliser l'API publique de VC pour gérer les coûts en démarrant/arrêtant le moteur SQL d'un site selon les exigences d'utilisation.

À propos de GraphQL
-------------------

GraphQL est un langage de requêtes pour les API qui :

-   Décrit les fonctionnalités des API par le biais d'un schéma [fortement typé](https://graphql.org/learn/schema/)
    -   Découvrez les fonctionnalités prises en charge de l'API à travers un schéma type qui décrit tous les points d'entrée (requêtes/mutations) et le schéma des données renvoyées
    -   Le schéma GraphQL est défini par le biais du langage de définition de schéma (SDL, Schema Definition Language) de GraphQL
-   Permet aux clients de demander les éléments nécessaires par le biais de [Requêtes et mutations](https://graphql.org/learn/queries/)
    -   Les appels d'API GraphQL renvoient précisément les éléments demandés (ni plus ni moins)
    -   Les clients contrôlent les données requises

La spécification GraphQL officielle est disponible [ici](https://graphql.github.io/graphql-spec/June2018/).

Point de terminaison de l'API GraphQL
-------------------------------------

-   Authentification à l'aide des informations d'identification utilisateur de Teradata Vantage.
-   Le point de terminaison de l'API publique GraphQL de VC est le suivant : `https://api.cloud.vantage.teradata.com/graphql/`
-   Vous pouvez télécharger le langage de définition de schéma (SDL) de GraphQL à partir de : `https://api.cloud.vantage.teradata.com/graphql/sdl`
    -   Vous pouvez importer le SDL dans votre client pour faciliter la création de requêtes/mutations personnalisées

Appel de l'API GraphQL
----------------------

L'API GraphQL est un point de terminaison HTTP, semblable à une API REST. La différence réside dans le contenu de la demande (spécification GraphQL - SDL) par rapport au chemin d'accès au point de terminaison, aux en-têtes et au corps de la demande de l'API REST. Tous les appels au point de terminaison GraphQL (requêtes ou mutations) utilisent la méthode HTTP `POST`.

### Authentification

L'API GraphQL de VC est sécurisée à l'aide de l'authentification de base (reportez-vous à [RFC 7617](https://tools.ietf.org/html/rfc7617)). Pour effectuer des appels vers cette API (requête ou mutation GraphQL quelconque), l'en-tête `Authorization` suivant est requis :

``` sourceCode
{
...
"Authorization": "Basic <base64 encoded username:password>"
...
}
```

### Corps de la demande

Format du corps de la demande

``` sourceCode
{
  "operationName":"myOperationName",
  "query":"query myOperationName {...}"
}
```

### Exemple d'appel d'API avec cURL

Vous pouvez consulter un exemple d'appel d'arrêt du moteur SQL (mutation) avec cURL ci-dessous. Vous trouverez d'autres didacticiels et exemples dans la section [Mise en route](#Getting-Started) ci-dessus.

``` sourceCode
curl 'https://api.cloud.vantage.teradata.com/graphql' -H 'authorization: Basic <base64 encoded username:password>' -H 'content-type: application/json' --data-binary '{"operationName":"stopSqlEngine","variables":{},"query":"mutation stopSqlEngine { stopSqlEngine(siteId: \"TDICA01780PRD00\") {id, name, status, startTime, endTime, details }}"}'
```

Requêtes et mutations prises en charge (liste incomplète)
---------------------------------------------------------

### Requêtes

<table style="width:99%;">
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th>Requête</th>
<th>Entrées</th>
<th>Détails</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>API générales du site</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>api</td>
<td>n/a</td>
<td>Détails de la version de l'API</td>
</tr>
<tr class="odd">
<td>user</td>
<td>n/a</td>
<td>Obtenez les rôles de stratégie de l'utilisateur</td>
</tr>
<tr class="even">
<td>sites</td>
<td>n/a</td>
<td>Répertoriez vos sites Teradata</td>
</tr>
<tr class="odd">
<td>site</td>
<td>id (ID du site)</td>
<td>Obtenez des détails sur un site spécifique</td>
</tr>
<tr class="even">
<td>sqlEngine</td>
<td>siteId</td>
<td>Obtenez des détails sur un moteur SQL spécifique pour un ID du site donné</td>
</tr>
<tr class="odd">
<td>getSqlEngineOperation</td>
<td>siteId, operationId</td>
<td>Obtenez des détails sur une opération de moteur SQL spécifique</td>
</tr>
<tr class="even">
<td>mlEngine</td>
<td>siteId</td>
<td>Obtenez des détails sur un moteur ML spécifique pour un ID du site donné</td>
</tr>
<tr class="odd">
<td>getMlEngineOperation</td>
<td>siteId, operationId</td>
<td>Obtenez des détails sur une opération de moteur ML spécifique</td>
</tr>
<tr class="even">
<td>privateLink</td>
<td>siteId</td>
<td>Obtenez des informations de liaisons privées sur un site</td>
</tr>
<tr class="odd">
<td><strong>API système</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSystemUsage</td>
<td>usageQuery(siteId, startTime, endTime, namespace, dataPoints)</td>
<td>Obtenez des données d'utilisation pour un site</td>
</tr>
<tr class="odd">
<td>getNotifications</td>
<td>lastSeenNotificationTimestamp, lastEvaluatedKey(notificationId, userId, receivedTimestamp)</td>
<td>Obtenez des notifications globales pour un utilisateur</td>
</tr>
<tr class="even">
<td>getNotificationSettings</td>
<td>receivedTimestamp</td>
<td>Obtenez des paramètres de notifications d'e-mail globales pour un utilisateur</td>
</tr>
<tr class="odd">
<td>getAlerts</td>
<td>alertParams ( site_id, activity_type, engine_types, dept_id )</td>
<td>Obtenez l'ensemble des alarmes de seuil ou une liste filtrée de ces dernières pour cet utilisateur</td>
</tr>
<tr class="even">
<td>sandboxes</td>
<td></td>
<td>Obtenez tous les sandboxs de cet utilisateur</td>
</tr>
<tr class="odd">
<td>sandbox</td>
<td>sandboxId</td>
<td>Obtenez des informations sur un sandbox</td>
</tr>
<tr class="even">
<td><strong>Surveillance de la consommation</strong></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>getVantageUnits</td>
<td>aggregatesQuery</td>
<td>Obtenez des données d'utilisation des unités Vantage pour les sites activés par la surveillance de la consommation Vantage</td>
</tr>
<tr class="even">
<td>getCDSUsage</td>
<td>aggregatesQuery</td>
<td>Obtenez des données de stockage des données consommées pour les sites activés par la surveillance de la consommation Vantage</td>
</tr>
<tr class="odd">
<td>getQueryActivity</td>
<td>aggregatesQuery</td>
<td>Obtenez des données d'activité et d'utilisation des requêtes Vantage pour les sites activés par la surveillance de la consommation Vantage</td>
</tr>
<tr class="even">
<td>getWeeklyStats</td>
<td>aggregatesQuery</td>
<td>Obtenez des données de requêtes Vantage pour les sites activés par la surveillance de la consommation Vantage</td>
</tr>
<tr class="odd">
<td>getTokenUnits</td>
<td>aggregatesQuery</td>
<td>Obtenez des données de consommation des unités pour les sites activés par la surveillance de la consommation des unités</td>
</tr>
<tr class="even">
<td>getTokenStorage</td>
<td>aggregatesQuery</td>
<td>Obtenez des données de stockage de la consommation des unités pour les sites activés par la surveillance de la consommation des unités</td>
</tr>
<tr class="odd">
<td><em>aggregatesQuery (interval_type, activity_type (STORAGE, UNITS, VANTAGE_UNITS, CDS), site_id, engine_types, range_begin, range_end, grouping, dept_id)</em></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getForecast</td>
<td>siteId, numOfDays</td>
<td>Obtenez des données prévisionnelles d'utilisation des unités Vantage pour les sites activés par la surveillance de la consommation Vantage</td>
</tr>
<tr class="odd">
<td>getContracts</td>
<td>siteId</td>
<td>Obtenez des données de contrats pour les sites activés par la surveillance de la consommation Vantage</td>
</tr>
<tr class="even">
<td>getTokenContracts</td>
<td>siteId</td>
<td>Obtenez des données de contrats pour les sites activés par la surveillance de la consommation des unités</td>
</tr>
<tr class="odd">
<td><strong>Protection des données, Tâche de sauvegarde et de restauration</strong>s</td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSiteDataProtectionPlans</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Obtenez tous les plans de protection des données pour ce site</td>
</tr>
<tr class="odd">
<td>getCustomerDataProtectionPlans</td>
<td>page (number), pageSize (number)</td>
<td>Obtenez tous les plans de protection des données pour cet utilisateur</td>
</tr>
<tr class="even">
<td>getCustomerExecutionHistory</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Obtenez l'historique et l'état de toutes les tâches de cet utilisateur (vous pouvez filtrer par siteId)</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanExecutionHistory</td>
<td>siteId, jobId, page (number), pageSize (number)</td>
<td>Obtenez l'historique et l'état de toutes les exécutions d'une tâche spécifique</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanDetails</td>
<td>siteId, jobId, includeSettings (boolean)</td>
<td>Obtenez tous les détails d'une tâche spécifique de protection des données</td>
</tr>
<tr class="odd">
<td>getExecutionById</td>
<td>siteId, jobId, executionId</td>
<td>Obtenez les détails d'une exécution spécifique de tâche de protection des données</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanSchedules</td>
<td>siteId, jobId</td>
<td>Obtenez la liste des temps d'exécution planifiés pour une tâche de protection des données</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanScheduleDetails</td>
<td>siteId, jobId, scheduleId</td>
<td>Obtenez les détails spécifiques d'une exécution planifiée d'une tâche de protection des données</td>
</tr>
<tr class="even">
<td>getNextRuns</td>
<td>siteId, jobId, limit (number)</td>
<td>Obtenez la liste des prochaines exécutions planifiées d'une tâche de protection des données</td>
</tr>
<tr class="odd">
<td>getRetainedCopiesForDataProtectionPlan</td>
<td>siteId, jobId, page? (number), pageSize? (number)</td>
<td>Obtenez la liste des sauvegardes réussies stockées créées à partir d'une tâche de protection des données.</td>
</tr>
<tr class="even">
<td>getRetainedCopiesForSite</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Obtenez la liste des sauvegardes réussies stockées créées pour toutes les tâches de protection des données sur un site particulier.</td>
</tr>
<tr class="odd">
<td>getRetainedCopies</td>
<td>page (number), pageSize (number)</td>
<td>Obtenez la liste des sauvegardes réussies stockées créées pour cet utilisateur.</td>
</tr>
<tr class="even">
<td>getSiteDatabases</td>
<td>siteId</td>
<td>Chargez la liste des bases de données du site pour la restauration sur une autre base de données.</td>
</tr>
<tr class="odd">
<td>getDatabaseObjects</td>
<td>siteId, xAuthCredential, objectName, objectType, search, page (number), pageSize (number)</td>
<td>Obtenez la liste d'objets existants dans la base de données pour choisir ceux que vous souhaitez sauvegarder</td>
</tr>
<tr class="even">
<td>restoreAuthenticationCheck</td>
<td>siteId</td>
<td>Vérifiez si l'utilisateur dispose des informations d'identification d'authentification appropriées pour effectuer une restauration sur les objets sélectionnés</td>
</tr>
<tr class="odd">
<td>getDRDetails</td>
<td>siteId, actionType(getTargets, getDRDetails)</td>
<td>Obtenez les détails de la tentative de récupération d'urgence des instantanés pour un site</td>
</tr>
<tr class="even">
<td>getFailoverDetails</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Obtenez les détails du basculement de récupération d'urgence des instantanés pour un site</td>
</tr>
<tr class="odd">
<td>getBackupJobObjects</td>
<td>siteId, jobId, executionId</td>
<td>Obtenez les objets enregistrés ciblés pour une sauvegarde DSA spécifique</td>
</tr>
<tr class="even">
<td>getRestoreHistory</td>
<td>siteId, backupJobId</td>
<td>Obtenez l'historique de toutes les sauvegardes DSA pour un utilisateur, ou propres à un site, ou pour une tâche de sauvegarde spécifique</td>
</tr>
<tr class="odd">
<td>getRestoreExecutions</td>
<td>siteId, jobId, executionId, restoreJobId</td>
<td>Obtenez la liste des tentatives pour une exécution/tâche de sauvegarde spécifique</td>
</tr>
<tr class="even">
<td>getRestoreExecutionDetails</td>
<td>siteId, jobId, executionId, restoreExecutionId</td>
<td>Obtenez les détails d'une tentative d'exécution pour une restauration DSA</td>
</tr>
</tbody>
</table>

### Mutations

<table style="width:99%;">
<colgroup>
<col style="width: 25%" />
<col style="width: 37%" />
<col style="width: 37%" />
</colgroup>
<thead>
<tr class="header">
<th>Mutation</th>
<th>Entrées</th>
<th>Détails</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>API générales du site</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>startSqlEngine</td>
<td>siteId (ID du site pour le moteur SQL)</td>
<td>Démarrez le moteur SQL pour l'ID du site donné.</td>
</tr>
<tr class="odd">
<td>stopSqlEngine</td>
<td>siteId (ID du site pour le moteur SQL)</td>
<td>Arrêtez le moteur SQL pour l'ID du site donné.</td>
</tr>
<tr class="even">
<td>scaleOutInSqlEngine</td>
<td>siteId (ID du site pour le moteur SQL), nodeCount (nombre de nœuds pour lesquels vous souhaitez augmenter/réduire la taille)</td>
<td>Montez/diminuez en puissance le moteur SQL vers le nombre de nœuds fourni pour l'ID du site donné.</td>
</tr>
<tr class="odd">
<td>scaleUpDownSqlEngine</td>
<td>siteId (ID du site pour le moteur SQL), instanceType (type d'instance de nœud à remplacer)</td>
<td>Augmentez/réduisez la taille du moteur SQL vers le type d'instance fourni pour l'ID du site donné.</td>
</tr>
<tr class="even">
<td>storageResizeSqlEngine</td>
<td>siteId (ID du site pour le moteur SQL), value (nouvelle valeur de taille de stockage), units (unités de taille de stockage)</td>
<td>Redimensionnement du stockage pour le moteur SQL vers la valeur totale fournie en unités.</td>
</tr>
<tr class="odd">
<td>startMlEngine</td>
<td>siteId (ID du site pour le moteur ML)</td>
<td>Démarrez le moteur ML pour l'ID du site donné.</td>
</tr>
<tr class="even">
<td>stopMlEngine</td>
<td>siteId (ID du site pour le moteur ML)</td>
<td>Arrêtez le moteur ML pour l'ID du site donné.</td>
</tr>
<tr class="odd">
<td>addPrivateLinkUsers</td>
<td>id, siteId, users (liste d'utilisateurs)</td>
<td>Ajoutez des utilisateurs de privatelink à la liste allowlist pour les connexions de liaisons privées</td>
</tr>
<tr class="even">
<td>removePrivateLinkUsers</td>
<td>id, siteId, users (liste d'utilisateurs)</td>
<td>Supprimez les utilisateurs de privatelink de la liste allowlist pour les connexions de liaisons privées</td>
</tr>
<tr class="odd">
<td><strong>API système</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>assumeRole</td>
<td>targetRole (ROLE)</td>
<td>Modifiez/assumez le rôle de votre utilisateur.</td>
</tr>
<tr class="odd">
<td>createAlert</td>
<td>alert ()</td>
<td>Créez une alarme de seuil</td>
</tr>
<tr class="even">
<td>updateAlert</td>
<td>alertId, alert ()</td>
<td>Mettez à jour une alarme de seuil</td>
</tr>
<tr class="odd">
<td>deleteAlerts</td>
<td>alertIds</td>
<td>Supprimez plusieurs alarmes par liste d'ID</td>
</tr>
<tr class="even">
<td>toggleGlobalNotification</td>
<td>updatedSubscription(email, topicName, channelName)</td>
<td>Abonnez votre utilisateur à une rubrique de notification</td>
</tr>
<tr class="odd">
<td>createSandbox</td>
<td>name, parentSiteId (siteId)</td>
<td>Créez une copie de sandbox d'un site</td>
</tr>
<tr class="even">
<td>deleteSandbox</td>
<td>sandboxId</td>
<td>Demandez la suppression d'un sandbox</td>
</tr>
<tr class="odd">
<td><strong>Protection des données, tâches de sauvegarde et de restauration</strong></td>
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
<td>Créez un plan de protection des données pour un site</td>
<td></td>
</tr>
<tr class="even">
<td>updateDataProtectionSettings</td>
<td>siteId, jobId, updateInput (name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism</td>
<td>(DSA, CDP, DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects(objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName, objectType))</td>
</tr>
<tr class="odd">
<td>targetRetentionCopiesCount (number), backupType(FULL, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Mettez à jour un plan de protection des données pour un site</td>
<td></td>
</tr>
<tr class="even">
<td>deleteDataProtectionPlan</td>
<td>siteId, jobId</td>
<td>Supprimez un plan de protection des données</td>
</tr>
<tr class="odd">
<td>createDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Créez une planification pour un plan de protection des données</td>
</tr>
<tr class="even">
<td>updateDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Mettez à jour une planification pour un plan de protection des données</td>
</tr>
<tr class="odd">
<td>deleteDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleId</td>
<td>Supprimez une planification pour un plan de protection des données</td>
</tr>
<tr class="even">
<td>previewDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Prévisualisez une planification pour un plan de protection des données</td>
</tr>
<tr class="odd">
<td>abortJob</td>
<td>siteId, jobId</td>
<td>Abandonnez un plan de protection des données en cours d'exécution</td>
</tr>
<tr class="even">
<td>instantJobRun</td>
<td>siteId, jobId, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR)</td>
<td>Exécutez immédiatement un plan de protection des données</td>
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
<td>(DSA’,CDP, DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects</td>
</tr>
<tr class="even">
<td>precheckRestore</td>
<td>siteId, executionId, jobId</td>
<td>Validez un instantané (par rapport au site donné s'il est fourni) pour sa capacité à être utilisé comme copie de restauration</td>
</tr>
<tr class="odd">
<td>protectRetainCopy</td>
<td>siteId, jobId, backupSetId, isRetained (boolean)</td>
<td>Protégez une copie conservée ou annulez sa protection</td>
</tr>
</tbody>
</table>

Gestion des erreurs
-------------------

Semblables aux API REST, les appels aux API GraphQL peuvent également renvoyer des réponses aux erreurs. Certains exemples peuvent être des erreurs non autorisées/interdites, une ressource introuvable, l'échec d'une opération, etc. Les détails des erreurs d'un appel d'API GraphQL sont contenus dans le corps de la réponse renvoyé.

Étant donné qu'un appel GraphQL peut couvrir plusieurs services, les objets erreur sont renvoyés sous la forme d'une liste de la partie `errors` du corps de la réponse. La structure d'un objet erreur est décrite ci-dessous :

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

Le code d'erreur est contenu dans la partie `extensions` de l'objet erreur dans un champ nommé `code`.

### Exemple de réponse non autorisée

Réponse à un appel d'API non autorisé.

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

### Exemple de réponse à une demande introuvable

Tentative d'obtention des détails d'un site inexistant.

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

### Exemple de réponse à une demande non valide

Appel d'une opération de démarrage de moteur SQL sur un site sur lequel cette opération n'est pas disponible actuellement (par exemple : le moteur SQL est déjà en cours d'exécution).

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

Bibliothèques clientes GraphQL
------------------------------

La liste ci-dessous contient des bibliothèques clientes connues pour l'appel des API GraphQL :

[Clients GraphQL](https://graphql.org/code/#graphql-clients)
