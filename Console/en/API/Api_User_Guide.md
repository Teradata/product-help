# Management Console GraphQL API

## Table of Contents

* [Getting Started](#Getting-Started)
* [Overview](#Overview)
* [About GraphQL](#About-Graphql)
* [The GraphQL API Endpoint](#The-GraphQL-API-Endpoint)
* [Calling the GraphQL API](#Calling-the-GraphQL-API)
    * [Authentication](#Authentication)
    * [Request Body](#Request-Body)
    * [Example API Call](#Example-API-Call)
* [Supported Queries and Mutations](#Supported-Queries-and-Mutations)
    * [Queries](#Queries)
    * [Mutations](#Mutations)
* [Error Handling](#Error-Handling)
* [GraphQL Client Libraries](#GraphQL-Client-Libraries)

## Getting Started

This section goes over several hands-on tutorials that can be followed for getting up and running quickly with working examples with the Management Console Public APIs.

* [Postman Tutorial](https://community.postman.com/t/postman-api-testing-tutorial-for-beginner/64511)
* [NodeJS Tutorial](https://nodejs.org/en/learn/getting-started/introduction-to-nodejs)
* [Python Tutorial](https://docs.python.org/3/tutorial/index.html)

## Overview

The Vantage Console (VC) API for VantageCloud Enterprise provides programatic access to common database elasticity operations.  With the availability of the new API, authorized users of VantageCloud Enterprise can now create custom scripts/apps (clients) to directly manage their Teradata systems.  For example, an administrator can use the VC Public API to manage costs by starting/stopping a Site's SQL Engine based on usage requirements.

## About GraphQL

GraphQL is a query language for APIs that:

* Describes API capabilities through a strongly [Typed Schema](https://graphql.org/learn/schema/)
    * Learn the supported capabilities of the API through a type schema that describes all entry points (Queries/Mutations) and the schema of the returned data
    * The GraphQL schema is defined through GraphQL's Schema Definition Language (SDL)
* Allows clients to Request what is needed through [Queries and Mutations](https://graphql.org/learn/queries/)
    * GraphQL API calls return exactly what was requested (not more or less)
    * Clients control the data they require

The Official GraphQL specification can be found [here](https://graphql.github.io/graphql-spec/June2018/).

## The GraphQL API Endpoint

* Authentiction with Teradata Vantage user credentials.
* The GraphQL VC Public API endpoint is: `https://api.cloud.vantage.teradata.com/graphql/`
* The GraphQL Schema Definition Language (SDL) can be downloaded from: `https://api.cloud.vantage.teradata.com/graphql/sdl`
    * The SDL can be imported in your client to help build custom query/mutations

## Calling the GraphQL API

The GraphQL API is an HTTP endpoint, similar to a REST API.  The difference is in the content of the request (GraphQL Specification - SDL) vs a REST API's endpoint path, headers, and request body.  All calls to the GraphQL endpoint (Queries or Mutations) will use the `POST` HTTP method.

### Authentication

The VC GraphQL API is secured with Basic Authentication (see [RFC 7617](https://tools.ietf.org/html/rfc7617)).  To make calls to this API (any GraphQL Query or Mutation), will require the following `Authorization` header:

```json
{
...
"Authorization": "Basic <base64 encoded username:password>"
...
}
```

### Request Body

Request body format

```json
{
  "operationName":"myOperationName",
  "query":"query myOperationName {...}"
}
```

### Example API Call with cURL

Example SQL Engine Stop call (Mutation) with cURL can be seen below.  Additional tutorials and examples can be found in the [Getting Started](#Getting-Started) section above.

```bash
curl 'https://api.cloud.vantage.teradata.com/graphql' -H 'authorization: Basic <base64 encoded username:password>' -H 'content-type: application/json' --data-binary '{"operationName":"stopSqlEngine","variables":{},"query":"mutation stopSqlEngine { stopSqlEngine(siteId: \"TDICA01780PRD00\") {id, name, status, startTime, endTime, details }}"}'
```

## Supported Queries and Mutations (incomplete list)  
  
  
### Queries

|Query | Inputs | Details|
|--- | --- | ---|
| **General Site APIs** |||
|api | n/a | API Version Details|
|user | n/a | Get your User's policy roles|
|sites | n/a | List your Teradata Sites|
|site | id (Site ID) | Get Details on a specific site|
|sqlEngine | siteId | Get details on a specific SQL Engine for a given Site ID|
|getSqlEngineOperation | siteId, operationId | Get details on a specific SQL Engine operation|
|mlEngine | siteId | Get details on a specific ML Engine for a given Site ID|
|getMlEngineOperation | siteId, operationId | Get details on a specific ML Engine operation|
|privateLink | siteId | Get private link information about a site|
| **System APIs** |||
|getSystemUsage | usageQuery(siteId, startTime, endTime, namespace, dataPoints) | Get utilization data for a site|
|getNotifications | lastSeenNotificationTimestamp, lastEvaluatedKey(notificationId,   userId,   receivedTimestamp) | Get global notifications for a user|
|getNotificationSettings | receivedTimestamp | Get settings for global email notifications for a user|
|getAlerts | alertParams ( site_id, activity_type, engine_types, dept_id ) | Get all or a filtered list of threshold alarms for this user|
|sandboxes | | Get all sandboxes for this user|
|sandbox | sandboxId | Get information about a sandbox|
| **Consumption Monitoring** |||
|getVantageUnits | aggregatesQuery | Get Vantage unit usage data for Vantage Consumption Monitoring enabled sites|
|getCDSUsage | aggregatesQuery  | Get Consumed data storage data for Vantage Consumption Monitoring enabled sites|
|getQueryActivity | aggregatesQuery  | Get Vantage query activity and usage data for Vantage Consumption Monitoring enabled sites|
|getWeeklyStats | aggregatesQuery  | Get Vantage query data for Vantage Consumption Monitoring enabled sites|
|getTokenUnits | aggregatesQuery  | Get Unit consumption data for Unit Consumption Monitoring enabled sites|
|getTokenStorage | aggregatesQuery  | Get Unit consumption storage data for Unit Consumption Monitoring enabled sites|
| *aggregatesQuery (interval_type,  activity_type (STORAGE, UNITS, VANTAGE_UNITS, CDS), site_id,  engine_types,  range_begin,  range_end,  grouping,  dept_id)* | ||
|getForecast  | siteId, numOfDays | Get forecasted Vantage unit usage data for Vantage Consumption Monitoring enabled sites|
|getContracts | siteId | Get contract data for Vantage Consumption Monitoring enabled sites|
|getTokenContracts | siteId | Get contract data for Unit Consumption Monitoring enabled sites|
| **Data protection, Backup and Restore Job**s|||
|getSiteDataProtectionPlans | siteId, page (number), pageSize (number) | Get all data protection plans for this site|
|getCustomerDataProtectionPlans | page (number), pageSize (number) | Get all data protection plans for this user|
|getCustomerExecutionHistory | siteId, page (number), pageSize (number) | Get history and status of all jobs for this user (can filter by siteId)|
|getDataProtectionPlanExecutionHistory | siteId, jobId, page (number), pageSize (number) | Get history and status of all runs of a specific job|
|getDataProtectionPlanDetails | siteId, jobId, includeSettings (boolean) | Get all details of a specific data protection job|
|getExecutionById | siteId, jobId, executionId | Get details of a specific data protection job run|
|getDataProtectionPlanSchedules | siteId, jobId | Get list of scheduled run times for a data protection job  |
|getDataProtectionPlanScheduleDetails | siteId, jobId, scheduleId | Get specific details for a scheduled run of a data protection job  |
|getNextRuns | siteId, jobId, limit (number) | Get list of upcoming scheduled data protection job runs|
|getRetainedCopiesForDataProtectionPlan | siteId, jobId, page? (number), pageSize? (number) | Get list of stored successful backups created from a data protection job.|
|getRetainedCopiesForSite | siteId, page (number), pageSize (number) | Get list of stored successful backups created for all data protection jobs on a particular site. |
|getRetainedCopies | page (number), pageSize (number) | Get list of stored successful backups created for this user. |
|getSiteDatabases | siteId | Load list of databases in the site for restoring to a different database.|
|getDatabaseObjects | siteId, xAuthCredential, objectName, objectType, search, page (number), pageSize (number) | Get list of objects existing on the database to choose which to backup|
|restoreAuthenticationCheck | siteId | Check whether the user has the proper auth credentials to do a Restore on the selected objects|
|getDRDetails | siteId, actionType(getTargets,  getDRDetails) |  Get snapshot disaster recovery attempt details for a site|
|getFailoverDetails | siteId, page (number), pageSize (number) | Get snapshot disaster recovery failover details for a site  |
|getBackupJobObjects | siteId, jobId, executionId | Get objects saved targeted for a specific DSA backup|
|getRestoreHistory |  siteId, backupJobId | Get history of all DSA backups for a user, or specific to a site, or for a specific backup job|
|getRestoreExecutions |  siteId, jobId, executionId, restoreJobId | Get list of execution attempts for a specific backup job/execution|
|getRestoreExecutionDetails |  siteId, jobId, executionId, restoreExecutionId | Get details of an execution attempt for a DSA restore|   
   
   
   
  
   


### Mutations

|Mutation | Inputs | Details|
|-- | --- | ---|
| **General Site APIs** |||
|startSqlEngine | siteId (Site ID for SQL Engine) | Start SQL Engine for given Site ID.|
|stopSqlEngine | siteId (Site ID for SQL Engine) | Stop SQL Engine for given Site ID.|
|scaleOutInSqlEngine | siteId (Site ID for SQL Engine), nodeCount (number of nodes to scale up/down to) | Scale Out or In SQL Engine to provided node count for given Site ID.|
|scaleUpDownSqlEngine | siteId (Site ID for SQL Engine), instanceType (node instance type to change to) | Scale Up or Down SQL Engine to provided instance type for given Site ID.|
|storageResizeSqlEngine | siteId (Site ID for SQL Engine), value (new storage size value), units (storage size units) | Storage Resize for SQL Engine to provided total value in units.|
|startMlEngine | siteId (Site ID for ML Engine) | Start ML Engine for given Site ID.|
|stopMlEngine | siteId (Site ID for ML Engine) | Stop ML Engine for given Site ID.|
|addPrivateLinkUsers | id, siteId, users (list of users) | Add privatelink users to the allowlist for private link connections|
|removePrivateLinkUsers | id, siteId, users(list of users) |  Remove privatelink users from the allowlist for private link connections|
| **System APIs** |||
|assumeRole | targetRole (ROLE) | Change/Assume role for your user.|
|createAlert | alert () | Create a threshold alarm|
|updateAlert | alertId, alert () | Update a threshold alarm|
|deleteAlerts | alertIds | Delete multiple alarms by list of ids|
|toggleGlobalNotification | updatedSubscription(email, topicName, channelName) | Subscribe your user to a notification topic|
|createSandbox | name, parentSiteId (siteId) | Create a sandbox copy of a site|
|deleteSandbox | sandboxId | Request a sandbox be deleted|
| **Data protection, Backup and Restore Jobs** |||
|createDataProtectionPlan | siteId, createInput (name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism (DSA, CDP, |DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects(objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName, objectType,))
|targetRetentionCopiesCount (number), backupType(FULL, SNAPSHOT, SNAPSHOT_DR)) | Create a data protection plan for a site|
|updateDataProtectionSettings | siteId, jobId, updateInput (name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism |(DSA, CDP, DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects(objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName, objectType))
|targetRetentionCopiesCount (number), backupType(FULL, SNAPSHOT, SNAPSHOT_DR)) |  Update a data protection plan for a site|
|deleteDataProtectionPlan | siteId, jobId | Delete a data protection plan|
|createDataProtectionPlanSchedule | siteId, jobId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR)) | Create a schedule for a data protection plan|
|updateDataProtectionPlanSchedule | siteId, jobId, scheduleId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR)) | Update a schedule for a data protection plan|
|deleteDataProtectionPlanSchedule | siteId, jobId, scheduleId | Delete a schedule for a data protection plan|
|previewDataProtectionPlanSchedule | siteId, jobId, scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR)) | Preview a schedule for a data protection plan|
|abortJob | siteId, jobId | Abort a running data protection plan|
|instantJobRun | siteId, jobId, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR) | Run a data protection plan right now|
|restoreData | siteId, executionId, jobId, settings (name, abortOnAccessRightsViolation (boolean), runAsCopyJob (boolean), restoreToDifferentDb (boolean), renameRestoredObjects (boolean), |skipStatistics (boolean), skipJoinHashIndexes (boolean), targetDatabase, tableNameSuffix, objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName, |objectType))) | Restore a retained copy to a site (same site or a different target)|
|updateRestoreJobSettings | siteId, jobId, backupExecutionId, updateInput(name, abortOnAccessRightsViolation (boolean), runAsCopyJob (boolean), restoreToDifferentDb (boolean), renameRestoredObjects |(boolean), skipStatistics (boolean), skipJoinHashIndexes (boolean), targetDatabase, tableNameSuffix, objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects |(objectName, objectType))) | Update the settings for a restore job|
|failOverData | siteId, executionId, jobId, failOverInput ( name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism |(DSA',CDP, DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects |(objectName, objectType)), targetRetentionCopiesCount (number), backupType(FULL, SNAPSHOT, SNAPSHOT_DR)) | Creates failover job with information on failover to be completed.|
|precheckRestore | siteId, executionId, jobId | Validate a snapshot (against the given site if provided) for its ability to be used as a restore copy|
|protectRetainCopy | siteId, jobId, backupSetId, isRetained (boolean) | Protect or unprotect a retained copy|


## Error Handling

Similar to REST APIs, calls to GraphQL APIs can also return error responses.  Some examples can be unauthorized/forbidden errors, resource not found, operation failed, etc. Error details from a GraphQL API call are contained in the returned response body.

Since a GraphQL call can span multiple services, error objects are returned as a list in the `errors` portion of the response body.  The structure of an error object is as described below:

```bash
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

The error code is contained in the `extensions` portion of the error object in a field named `code`.

### Example Unathorized Response

The response to an unauthorized API call.

```bash
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

### Example Not Found Request Response

Trying to get the details of a Site that does not exist.

```bash
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

### Example Invalid Request Response

Calling SQL Engine Start operation on a Site where that operation is currently not available (e.g. SQL Engine is already running).

```bash
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

## GraphQL Client Libraries

The list below contains popular client libraries for calling GraphQL APIs:

[GraphQL Clients](https://graphql.org/code/#graphql-clients)
