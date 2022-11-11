Verwaltungskonsole der GraphQL-API
==================================

Inhaltsverzeichnis
------------------

-   [Erste Schritte](#Getting-Started)
-   [Übersicht](#Übersicht)
-   [Info zu GraphQL](#About-Graphql)
-   [Der Endpoint der GraphQL-API](#The-GraphQL-API-Endpoint)
-   [Aufrufen der GraphQL-API](#Calling-the-GraphQL-API)
    -   [Authentifizierung](#Authentifizierung)
    -   [Anforderungstext](#Request-Body)
    -   [Beispiel eines API-Aufrufs](#Example-API-Call)
-   [Unterstützte Abfragen und Mutationen](#Supported-Queries-and-Mutations)
    -   [Abfragen](#Abfragen)
    -   [Mutationen](#Mutationen)
-   [Fehlerbehebung](#Error-Handling)
-   [GraphQL-Clientbibliotheken](#GraphQL-Client-Libraries)

Erste Schritte
--------------

In diesem Abschnitt werden mehrere Praxis-Tutorials mit Anweisungen zum schnellen Einrichten und Ausführen funktionierender Beispiele mit den öffentlichen APIs der Verwaltungskonsole vorgestellt.

-   [Postman-Tutorial](./appendix/postman/tutorial.md)
-   [NodeJS-Tutorial](./appendix/nodejs/tutorial.md)
-   [Python-Tutorial](./appendix/python/tutorial.md)

Übersicht
---------

Die Vantage Console-API (VC) für VantageCloud Enterprise bietet programmgesteuerten Zugriff auf allgemeine Operationen elastischer Datenbanken. Mit der neuen API können autorisierte Benutzer von VantageCloud Enterprise jetzt allgemeine Skripts/Apps (Clients) erstellen und ihre Teradata-Systeme direkt verwalten. Administratoren können die öffentliche VC-API beispielsweise zum Verwalten von Kosten verwenden, indem sie die SQL-Engine einer Site je nach Nutzungsanforderungen starten/stoppen.

Info zu GraphQL
---------------

Bei GraphQL handelt es sich um eine Abfragesprache für APIs, die:

-   API-Funktionen über ein stark [typisiertes Schema beschreibt](https://graphql.org/learn/schema/)
    -   Machen Sie sich mit den unterstützten Funktionen der API über ein Typenschema vertraut, in dem alle Einstiegspunkte (Abfragen/Mutationen) und das Schema der zurückgegebenen Daten beschrieben werden
    -   Das GraphQL-Schema wird über die SDL (Schema Definition Language) von GraphQL definiert
-   Ermöglicht Clients, benötigte Elemente über [Abfragen und Mutationen](https://graphql.org/learn/queries/)
    -   GraphQL-API-Aufrufe geben genaue der Anforderung entsprechende Daten zurück (nicht mehr und nicht weniger)
    -   Clients steuern die benötigten Daten

    anzufordern

Die offizielle GraphQL-Spezifikation finden Sie unter [hier](https://graphql.github.io/graphql-spec/June2018/).

Der Endpoint der GraphQL-API
----------------------------

-   Authentifizierung mit Teradata Vantage-Benutzeranmeldedaten
-   Der öffentliche API-Endpoint der GraphQL-VC lautet: `https://api.cloud.vantage.teradata.com/graphql/`
-   Die GraphQL-SDL (Schema Definition Language) kann hier heruntergeladen werden: `https://api.cloud.vantage.teradata.com/graphql/sdl`
    -   Die SDL kann in Ihren Client importiert werden und Unterstützung bei der Erstellung benutzerdefinierter Abfragen/Mutationen bieten

Aufrufen der GraphQL-API
------------------------

Bei der GraphQL-API handelt es sich ähnlich wie bei einer REST-API um einen HTTP-Endpoint. Der Unterschied besteht im Inhalt der Anfrage (GraphQL-Spezifikation – SDL) verglichen mit dem Endpoint-Pfad, den Headern und dem Anforderungstext einer Rest-API. Alle Aufrufe des GraphQL-Endpoints (Abfragen oder Mutationen ) verwenden die `POST`-HTTP-Methode.

### Authentifizierung

Die GraphQL-API der VC wird mit Standardauthentifizierung (siehe [RFC 7617](https://tools.ietf.org/html/rfc7617)) gesichert. Zum Aufrufen dieser API (beliebige GraphQL-Abfrage oder -Mutation) wird folgender `Authorization`-Header benötigt:

``` sourceCode
{
...
"Authorization": "Basic <base64 encoded username:password>"
...
}
```

### Anforderungstext

Format des Anforderungstexts

``` sourceCode
{
  "operationName":"myOperationName",
  "query":"query myOperationName {...}"
}
```

### Beispiel eines API-Aufrufs mit cURL

Ein Beispiel für einen Stopp-Aufruf (Mutation) der SQL-Engine mit cURL wird im Folgenden angezeigt. Weitere Tutorials und Beispiele finden Sie oben im [Erste Schritte](#Getting-Started)-Abschnitt.

``` sourceCode
curl 'https://api.cloud.vantage.teradata.com/graphql' -H 'authorization: Basic <base64 encoded username:password>' -H 'content-type: application/json' --data-binary '{"operationName":"stopSqlEngine","variables":{},"query":"mutation stopSqlEngine { stopSqlEngine(siteId: \"TDICA01780PRD00\") {id, name, status, startTime, endTime, details }}"}'
```

Unterstützte Abfragen und Mutationen (unvollständige Liste)
-----------------------------------------------------------

### Abfragen

<table style="width:99%;">
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th>Abfrage</th>
<th>Eingaben</th>
<th>Details</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>Allgemeine Site-APIs</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>api</td>
<td>n/a</td>
<td>Details der API-Version</td>
</tr>
<tr class="odd">
<td>user</td>
<td>n/a</td>
<td>Richtlinienrollen des Benutzers abrufen</td>
</tr>
<tr class="even">
<td>sites</td>
<td>n/a</td>
<td>Ihre Teradata-Sites auflisten</td>
</tr>
<tr class="odd">
<td>site</td>
<td>ID (Site-ID)</td>
<td>Details einer bestimmten Site abrufen</td>
</tr>
<tr class="even">
<td>sqlEngine</td>
<td>siteId</td>
<td>Details einer spezifischen SQL-Engine für eine bestimmte Site-ID abrufen</td>
</tr>
<tr class="odd">
<td>getSqlEngineOperation</td>
<td>siteId, operationId</td>
<td>Details einer spezifischen Operation der SQL-Engine abrufen</td>
</tr>
<tr class="even">
<td>mlEngine</td>
<td>siteId</td>
<td>Details einer spezifischen ML-Engine für eine bestimmte Site-ID abrufen</td>
</tr>
<tr class="odd">
<td>getMlEngineOperation</td>
<td>siteId, operationId</td>
<td>Details einer spezifischen Operation der ML-Engine abrufen</td>
</tr>
<tr class="even">
<td>privateLink</td>
<td>siteId</td>
<td>Informationen zu privaten Links einer Site abrufen</td>
</tr>
<tr class="odd">
<td><strong>System-APIs</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSystemUsage</td>
<td>usageQuery(siteId, startTime, endTime, namespace, dataPoints)</td>
<td>Nutzungsdaten für eine Site abrufen</td>
</tr>
<tr class="odd">
<td>getNotifications</td>
<td>lastSeenNotificationTimestamp, lastEvaluatedKey(notificationId, userId, receivedTimestamp)</td>
<td>Globale Benachrichtigungen für einen Benutzer abrufen</td>
</tr>
<tr class="even">
<td>getNotificationSettings</td>
<td>receivedTimestamp</td>
<td>Einstellungen für globale E-Mail-Benachrichtigungen für einen Benutzer abrufen</td>
</tr>
<tr class="odd">
<td>getAlerts</td>
<td>alertParams ( site_id, activity_type, engine_types, dept_id )</td>
<td>Alle oder eine gefilterte Liste von Schwellenwertalarmen abrufen</td>
</tr>
<tr class="even">
<td>Sandboxes</td>
<td></td>
<td>Alle Sandboxes für diesen Benutzer abrufen</td>
</tr>
<tr class="odd">
<td>sandbox</td>
<td>sandboxId</td>
<td>Informationen zu einer Sandbox abrufen</td>
</tr>
<tr class="even">
<td><strong>Consumption Monitoring</strong></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>getVantageUnits</td>
<td>aggregatesQuery</td>
<td>Nutzungsdaten der Vantage-Einheit für Vantage Consumption Monitoring-fähige Sites abrufen</td>
</tr>
<tr class="even">
<td>getCDSUsage</td>
<td>aggregatesQuery</td>
<td>Speicherdaten der Verbrauchsdaten für Vantage Consumption Monitoring-fähige Sites abrufen</td>
</tr>
<tr class="odd">
<td>getQueryActivity</td>
<td>aggregatesQuery</td>
<td>Aktivitäts- und Nutzungsdaten der Vantage-Abfrage für Vantage Consumption Monitoring-fähige Sites abrufen</td>
</tr>
<tr class="even">
<td>getWeeklyStats</td>
<td>aggregatesQuery</td>
<td>Vantage-Abfragedaten für Vantage Consumption Monitoring-fähige Sites abrufen</td>
</tr>
<tr class="odd">
<td>getTokenUnits</td>
<td>aggregatesQuery</td>
<td>Verbrauchsdaten der Einheit für Vantage Consumption Monitoring-fähige Sites abrufen</td>
</tr>
<tr class="even">
<td>getTokenStorage</td>
<td>aggregatesQuery</td>
<td>Speicherdaten zum Verbrauch je Einheit für Unit Consumption Monitoring-fähige Sites abrufen</td>
</tr>
<tr class="odd">
<td><em>aggregatesQuery (interval_type, activity_type (STORAGE, UNITS, VANTAGE_UNITS, CDS), site_id, engine_types, range_begin, range_end, grouping, dept_id)</em></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getForecast</td>
<td>siteId, numOfDays</td>
<td>Prognostizierte Nutzungsdaten der Vantage-Einheit für Vantage Consumption Monitoring-fähige Sites abrufen</td>
</tr>
<tr class="odd">
<td>getContracts</td>
<td>siteId</td>
<td>Vertragsdaten für Vantage Consumption Monitoring-fähige Sites abrufen</td>
</tr>
<tr class="even">
<td>getTokenContracts</td>
<td>siteId</td>
<td>Vertragsdaten für Unit Consumption Monitoring-fähige Sites abrufen</td>
</tr>
<tr class="odd">
<td><strong>Datenschutz-, Sicherungs- und Wiederherstellungsauftrag</strong>s</td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSiteDataProtectionPlans</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Alle Datenschutzpläne für diese Site abrufen</td>
</tr>
<tr class="odd">
<td>getCustomerDataProtectionPlans</td>
<td>page (number), pageSize (number)</td>
<td>Alle Datenschutzpläne für diesen Benutzer abrufen</td>
</tr>
<tr class="even">
<td>getCustomerExecutionHistory</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Verlauf und Status aller Aufträge für diesen Benutzer abrufen (Filtern nach Site-ID möglich)</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanExecutionHistory</td>
<td>siteId, jobId, page (number), pageSize (number)</td>
<td>Verlauf und Status aller Ausführungen einer bestimmten Aufgabe abrufen</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanDetails</td>
<td>siteId, jobId, includeSettings (boolean)</td>
<td>Alle Details eines bestimmten Datenschutzauftrags abrufen</td>
</tr>
<tr class="odd">
<td>getExecutionById</td>
<td>siteId, jobId, executionId</td>
<td>Details zur Ausführung eines bestimmten Datenschutzauftrags abrufen</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanSchedules</td>
<td>siteId, jobId</td>
<td>Liste der geplanten Laufzeiten für einen Datenschutzauftrags abrufen</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanScheduleDetails</td>
<td>siteId, jobId, scheduleId</td>
<td>Bestimmte Details für eine geplante Ausführung eines Datenschutzauftrags abrufen</td>
</tr>
<tr class="even">
<td>getNextRuns</td>
<td>siteId, jobId, limit (number)</td>
<td>Liste bevorstehender geplanter Ausführungen eines Datenschutzauftrags abrufen</td>
</tr>
<tr class="odd">
<td>getRetainedCopiesForDataProtectionPlan</td>
<td>siteId, jobId, page? (number), pageSize? (number)</td>
<td>Liste gespeicherter erfolgreicher Sicherungen abrufen, die anhand eines Datenschutzauftrags erstellt wurden.</td>
</tr>
<tr class="even">
<td>getRetainedCopiesForSite</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Liste gespeicherter erfolgreicher Sicherungen abrufen, die für alle Datenschutzaufträge auf einer bestimmten Site erstellt wurden.</td>
</tr>
<tr class="odd">
<td>getRetainedCopies</td>
<td>page (number), pageSize (number)</td>
<td>Liste gespeicherter erfolgreicher Sicherungen abrufen, die für diesen Benutzer erstellt wurden.</td>
</tr>
<tr class="even">
<td>getSiteDatabases</td>
<td>siteId</td>
<td>Liste der Datenbanken auf der Site zur Wiederherstellung in eine andere Datenbank laden.</td>
</tr>
<tr class="odd">
<td>getDatabaseObjects</td>
<td>siteId, xAuthCredential, objectName, objectType, search, page (number), pageSize (number)</td>
<td>Liste der in der Datenbank vorhandenen Objekte abrufen, um die zu sichernden Objekte auszuwählen</td>
</tr>
<tr class="even">
<td>restoreAuthenticationCheck</td>
<td>siteId</td>
<td>Sicherstellen, dass der Benutzer über die entsprechenden Authentifizierungsanmeldedaten zum Durchführen einer Wiederherstellung der ausgewählte Objekte verfügt</td>
</tr>
<tr class="odd">
<td>getDRDetails</td>
<td>siteId, actionType(getTargets, getDRDetails)</td>
<td>Details zur Notfallwiederherstellung eines Snapshots für eine Site abrufen</td>
</tr>
<tr class="even">
<td>getFailoverDetails</td>
<td>siteId, page (number), pageSize (number)</td>
<td>Details zum Notfallwiederherstellungs-Failover eines Snapshots für eine Site abrufen</td>
</tr>
<tr class="odd">
<td>getBackupJobObjects</td>
<td>siteId, jobId, executionId</td>
<td>Objekte abrufen, die für eine bestimmte DSA-Sicherung gespeichert wurden</td>
</tr>
<tr class="even">
<td>getRestoreHistory</td>
<td>siteId, backupJobId</td>
<td>Verlauf aller DSA-Sicherungen für einen bestimmten Benutzer, eine bestimmte Site oder einen bestimmten Sicherungsauftrag abrufen</td>
</tr>
<tr class="odd">
<td>getRestoreExecutions</td>
<td>siteId, jobId, executionId, restoreJobId</td>
<td>Liste der Ausführungsversuche für einen bestimmten Sicherungsauftrag/eine bestimmte Sicherungsausführung abrufen</td>
</tr>
<tr class="even">
<td>getRestoreExecutionDetails</td>
<td>siteId, jobId, executionId, restoreExecutionId</td>
<td>Details eines Ausführungsversuchs für eine DSA-Wiederherstellung abrufen</td>
</tr>
</tbody>
</table>

### Mutationen

<table style="width:99%;">
<colgroup>
<col style="width: 25%" />
<col style="width: 37%" />
<col style="width: 37%" />
</colgroup>
<thead>
<tr class="header">
<th>Mutation</th>
<th>Eingaben</th>
<th>Details</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>Allgemeine Site-APIs</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>startSqlEngine</td>
<td>siteId (Site-ID für SQL-Engine)</td>
<td>SQL-Engine für bestimmte Site-ID starten.</td>
</tr>
<tr class="odd">
<td>stopSqlEngine</td>
<td>siteId (Site-ID für SQL-Engine)</td>
<td>SQL-Engine für bestimmte Site-ID stoppen.</td>
</tr>
<tr class="even">
<td>scaleOutInSqlEngine</td>
<td>siteId (Site-ID für SQL-Engine), nodeCount (Anzahl der hoch-/herunterzuskalierenden Knoten)</td>
<td>SQL-Engine vertikal oder horizontal auf die bereitgestellte Knotenanzahl für eine bestimmte Site-ID skalieren.</td>
</tr>
<tr class="odd">
<td>scaleUpDownSqlEngine</td>
<td>siteId (Site-ID für SQL-Engine), instanceType (Typ der Knoteninstanz, zu dem gewechselt werden soll)</td>
<td>SQL-Engine auf den bereitgestellten Instanztyp für eine bestimmte Site-ID hoch- oder herunterskalieren.</td>
</tr>
<tr class="even">
<td>storageResizeSqlEngine</td>
<td>siteId (Site-ID für SQL-Engine), value (neuer Wert für Speichergröße), units (Einheiten der Speichergröße)</td>
<td>Speichergröße für SQL-Engine auf den bereitgestellten Gesamtwert in Einheiten ändern.</td>
</tr>
<tr class="odd">
<td>startMlEngine</td>
<td>siteId (Site-ID für ML-Engine)</td>
<td>ML-Engine für bestimmte Site-ID starten.</td>
</tr>
<tr class="even">
<td>stopMlEngine</td>
<td>siteId (Site-ID für ML-Engine)</td>
<td>ML-Engine für bestimmte Site-ID stoppen.</td>
</tr>
<tr class="odd">
<td>addPrivateLinkUsers</td>
<td>id, siteId, users (Liste der Benutzer)</td>
<td>Private Link-Benutzer zur Positivliste für Private Link-Verbindungen hinzufügen</td>
</tr>
<tr class="even">
<td>removePrivateLinkUsers</td>
<td>id, siteId, users (Liste der Benutzer)</td>
<td>Private Link-Benutzer aus der Positivliste für Private Link-Verbindungen entfernen</td>
</tr>
<tr class="odd">
<td><strong>System-APIs</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>assumeRole</td>
<td>targetRole (ROLE)</td>
<td>Rolle für den Benutzer ändern/annehmen</td>
</tr>
<tr class="odd">
<td>createAlert</td>
<td>alert ()</td>
<td>Schwellenwertalarm erstellen</td>
</tr>
<tr class="even">
<td>updateAlert</td>
<td>alertId, alert ()</td>
<td>Schwellenwertalarm aktualisieren</td>
</tr>
<tr class="odd">
<td>deleteAlerts</td>
<td>alertIds</td>
<td>Mehrere Alarme nach ID-Liste löschen</td>
</tr>
<tr class="even">
<td>toggleGlobalNotification</td>
<td>updatedSubscription(email, topicName, channelName)</td>
<td>Benachrichtigungsthema für den Benutzer abonnieren</td>
</tr>
<tr class="odd">
<td>createSandbox</td>
<td>name, parentSiteId (siteId)</td>
<td>Sandbox-Kopie einer Site erstellen</td>
</tr>
<tr class="even">
<td>deleteSandbox</td>
<td>sandboxId</td>
<td>Löschen einer Sandbox anfordern</td>
</tr>
<tr class="odd">
<td><strong>Datenschutz-, Sicherungs- und Wiederherstellungsaufträge</strong></td>
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
<td>Datenschutzplan für eine Site erstellen</td>
<td></td>
</tr>
<tr class="even">
<td>updateDataProtectionSettings</td>
<td>siteId, jobId, updateInput (name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism</td>
<td>(DSA, CDP, DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects(objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName, objectType))</td>
</tr>
<tr class="odd">
<td>targetRetentionCopiesCount (number), backupType(FULL, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Datenschutzplan für eine Site aktualisieren</td>
<td></td>
</tr>
<tr class="even">
<td>deleteDataProtectionPlan</td>
<td>siteId, jobId</td>
<td>Datenschutzplan löschen</td>
</tr>
<tr class="odd">
<td>createDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Zeitplan für einen Datenschutzplan erstellen</td>
</tr>
<tr class="even">
<td>updateDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Zeitplan für einen Datenschutzplan aktualisieren</td>
</tr>
<tr class="odd">
<td>deleteDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleId</td>
<td>Zeitplan für einen Datenschutzplan löschen</td>
</tr>
<tr class="even">
<td>previewDataProtectionPlanSchedule</td>
<td>siteId, jobId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>Zeitplan für einen Datenschutzplan in der Vorschau anzeigen</td>
</tr>
<tr class="odd">
<td>abortJob</td>
<td>siteId, jobId</td>
<td>Laufenden Datenschutzplan abbrechen</td>
</tr>
<tr class="even">
<td>instantJobRun</td>
<td>siteId, jobId, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR)</td>
<td>Datenschutzplan jetzt ausführen</td>
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
<td>Snapshot (gegebenenfalls für die angegebene Site) auf seine Eignung als Wiederherstellungskopie überprüfen</td>
</tr>
<tr class="odd">
<td>protectRetainCopy</td>
<td>siteId, jobId, backupSetId, isRetained (boolean)</td>
<td>Beibehaltene Kopie schützen oder deren Schutz aufheben</td>
</tr>
</tbody>
</table>

Fehlerbehebung
--------------

Ebenso wie REST-APIs können Aufrufe der GraphQL-APIs Fehlerantworten zurückgeben. Zu den Beispielen gehören unter anderem Fehler vom Typ "Nicht autorisiert/Verboten", "Ressource nicht gefunden", "Vorgang fehlgeschlagen" usw. Fehlerdetails aus einem GraphQL-API-Aufruf sind im zurückgegebenen Antworttext enthalten.

Da ein GraphQL-Aufruf mehrere Dienste umfassen kann, werden Fehlerobjekte als Liste im `errors` Teil des Antworttexts zurückgegeben. Die Struktur eines Fehlerobjekts wird im Folgenden beschrieben:

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

Der Fehlercode befindet sich im `extensions` Teil des Fehlerobjekts in einem Feld mit der Bezeichnung `code`.

### Beispiel für eine Antwort vom Typ "Nicht autorisiert"

Die Antwort auf einen nicht autorisierten API-Aufruf.

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

### Beispiel für eine Antwort vom Typ "Anfrage nicht gefunden"

Versuch, die Details einer nicht vorhandenen Site abzurufen.

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

### Beispiel für eine Antwort vom Typ "Ungültige Anfrage"

Aufrufen eines SQL-Engine-Startvorgangs auf einer Site, auf der dieser Vorgang aktuell nicht verfügbar ist (SQL-Engine wird beispielsweise bereits ausgeführt).

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

GraphQL-Clientbibliotheken
--------------------------

Die folgende Liste enthält bekannte Clientbibliotheken zum Aufrufen von GraphQL-APIs:

[GraphQL-Clients](https://graphql.org/code/#graphql-clients)
