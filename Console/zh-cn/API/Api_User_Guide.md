管理控制台 GraphQL API
======================

目录
----

-   [开始](#Getting-Started)
-   [概览](#概览)
-   [关于 GraphQL](#About-Graphql)
-   [GraphQL API 端点](#The-GraphQL-API-Endpoint)
-   [调用 GraphQL API](#Calling-the-GraphQL-API)
    -   [身份验证](#身份验证)
    -   [请求正文](#Request-Body)
    -   [API 调用示例](#Example-API-Call)
-   [支持的查询和突变](#Supported-Queries-and-Mutations)
    -   [查询](#查询)
    -   [突变](#突变)
-   [错误处理](#Error-Handling)
-   [GraphQL 客户端库](#GraphQL-Client-Libraries)

开始
----

此部分将介绍几个实践教程，学习后可以快速启动和运行管理控制台公共 API 的工作示例。

-   [Postman 教程](./appendix/postman/tutorial.md)
-   [NodeJS 教程](./appendix/nodejs/tutorial.md)
-   [Python 教程](./appendix/python/tutorial.md)

概览
----

VantageCloud Enterprise 的 Vantage 控制台 (VC) API 提供了对通用数据库弹性操作的编程访问权限。通过新的 API，VantageCloud Enterprise 的授权用户现在可以创建自定义脚本/应用程序（客户端）来直接管理他们的 Teradata 系统。例如，管理员可以使用 VC 公共 API 根据使用需求启动/停止站点的 SQL 引擎来管理成本。

关于 GraphQL
------------

GraphQL 是适用于 API 的查询语言：

-   通过强[类型架构](https://graphql.org/learn/schema/)描述 API 功能
    -   通过描述所有入口点（查询/突变）的类型架构和所返回数据的架构了解支持的 API 功能
    -   GraphQL 架构通过 GraphQL 的架构定义语言 (SDL) 定义。
-   允许客户端通过[查询和突变](https://graphql.org/learn/queries/)请求所需的内容
    -   GraphQL API 调用将准确返回所请求的内容（不多也不少）
    -   客户端可控制需要的数据

官方 GraphQL 规范可在[此处](https://graphql.github.io/graphql-spec/June2018/)找到。

GraphQL API 端点
----------------

-   使用 Teradata Vantage 用户凭据进行身份验证。
-   GraphQL VC 公共 API 端点：`https://api.cloud.vantage.teradata.com/graphql/`
-   GraphQL 架构定义语言 (SDL) 下载地址：`https://api.cloud.vantage.teradata.com/graphql/sdl`
    -   可在客户端中导入 SDL 以帮助构建自定义查询/突变

调用 GraphQL API
----------------

GraphQL API 是一个 HTTP 端点，类似于 REST API。区别在于请求的内容（GraphQL 规范 - SDL）与 REST API 的端点路径、标头和请求正文。所有对 GraphQL 端点（查询或突变）的调用都将使用 `POST` HTTP 方法。

### 身份验证

VC GraphQL API 通过基本身份验证获得保护（见[RFC 7617](https://tools.ietf.org/html/rfc7617)）。要调用此 API（任何 GraphQL 查询或突变），需要以下 `Authorization` 标头：

``` sourceCode
{
...
"Authorization": "Basic <base64 encoded username:password>"
...
}
```

### 请求正文

请求正文格式

``` sourceCode
{
  "operationName":"myOperationName",
  "query":"query myOperationName {...}"
}
```

### 使用 cURL 的 API 调用示例

下面是使用 cURL 的 SQL 引擎 Stop 调用（突变）示例。在上面的[开始](#Getting-Started)部分中可以找到更多的教程和示例。

``` sourceCode
curl 'https://api.cloud.vantage.teradata.com/graphql' -H 'authorization: Basic <base64 encoded username:password>' -H 'content-type: application/json' --data-binary '{"operationName":"stopSqlEngine","variables":{},"query":"mutation stopSqlEngine { stopSqlEngine(siteId: \"TDICA01780PRD00\") {id, name, status, startTime, endTime, details }}"}'
```

支持的查询和突变（不完整列表）
------------------------------

### 查询

<table style="width:99%;">
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th>查询</th>
<th>输入</th>
<th>详细信息</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>一般站点 API</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>api</td>
<td>n/a</td>
<td>API 版本详细信息</td>
</tr>
<tr class="odd">
<td>user</td>
<td>n/a</td>
<td>获取用户的策略角色</td>
</tr>
<tr class="even">
<td>sites</td>
<td>n/a</td>
<td>列出 Teradata 站点</td>
</tr>
<tr class="odd">
<td>site</td>
<td>ID（站点 ID）</td>
<td>获取有关特定站点的详细信息</td>
</tr>
<tr class="even">
<td>sqlEngine</td>
<td>siteId</td>
<td>获取给定站点 ID 对应的特定 SQL 引擎的详细信息</td>
</tr>
<tr class="odd">
<td>getSqlEngineOperation</td>
<td>siteId、operationId</td>
<td>获取有关特定 SQL 引擎操作的详细信息</td>
</tr>
<tr class="even">
<td>mlEngine</td>
<td>siteId</td>
<td>获取给定站点 ID 对应的特定 ML 引擎的详细信息</td>
</tr>
<tr class="odd">
<td>getMlEngineOperation</td>
<td>siteId、operationId</td>
<td>获取有关特定 ML 引擎操作的详细信息</td>
</tr>
<tr class="even">
<td>privateLink</td>
<td>siteId</td>
<td>获取有关站点的专用链接信息</td>
</tr>
<tr class="odd">
<td><strong>系统 API</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSystemUsage</td>
<td>usageQuery(siteId, startTime, endTime, namespace, dataPoints)</td>
<td>获取站点的使用情况数据</td>
</tr>
<tr class="odd">
<td>getNotifications</td>
<td>lastSeenNotificationTimestamp、lastEvaluatedKey(notificationId, userId, receivedTimestamp)</td>
<td>获取用户的全局通知</td>
</tr>
<tr class="even">
<td>getNotificationSettings</td>
<td>receivedTimestamp</td>
<td>获取用户的全局电子邮件通知设置</td>
</tr>
<tr class="odd">
<td>getAlerts</td>
<td>alertParams ( site_id, activity_type, engine_types, dept_id )</td>
<td>获取此用户的全部或经筛选的阈值警报列表</td>
</tr>
<tr class="even">
<td>sandboxes</td>
<td></td>
<td>获取此用户的所有沙盒</td>
</tr>
<tr class="odd">
<td>sandbox</td>
<td>sandboxId</td>
<td>获取有关沙盒的信息</td>
</tr>
<tr class="even">
<td><strong>消耗量监测</strong></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>getVantageUnits</td>
<td>aggregatesQuery</td>
<td>获取启用了 Vantage 消耗量监测的站点的 Vantage 单位使用率数据</td>
</tr>
<tr class="even">
<td>getCDSUsage</td>
<td>aggregatesQuery</td>
<td>获取启用了 Vantage 消耗量监测的站点的消耗数据存储数据</td>
</tr>
<tr class="odd">
<td>getQueryActivity</td>
<td>aggregatesQuery</td>
<td>获取启用了 Vantage 消耗量监测的站点的 Vantage 查询活动和使用率数据</td>
</tr>
<tr class="even">
<td>getWeeklyStats</td>
<td>aggregatesQuery</td>
<td>获取启用了 Vantage 消耗量监测的站点的 Vantage 查询数据</td>
</tr>
<tr class="odd">
<td>getTokenUnits</td>
<td>aggregatesQuery</td>
<td>获取启用了单位消耗量监测的站点的单位消耗量数据</td>
</tr>
<tr class="even">
<td>getTokenStorage</td>
<td>aggregatesQuery</td>
<td>获取启用了单位消耗量监测的站点的单位消耗量存储数据</td>
</tr>
<tr class="odd">
<td><em>aggregatesQuery (interval_type, activity_type (STORAGE, UNITS, VANTAGE_UNITS, CDS), site_id, engine_types, range_begin, range_end, grouping, dept_id)</em></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getForecast</td>
<td>siteId、numOfDays</td>
<td>获取启用了 Vantage 消耗量监测的站点的预测 Vantage 单位使用率数据</td>
</tr>
<tr class="odd">
<td>getContracts</td>
<td>siteId</td>
<td>获取启用了 Vantage 消耗量监测的站点的合同数据</td>
</tr>
<tr class="even">
<td>getTokenContracts</td>
<td>siteId</td>
<td>获取启用了单位消耗量监测的站点的合同数据</td>
</tr>
<tr class="odd">
<td><strong>数据保护、备份和恢复作业</strong>s</td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSiteDataProtectionPlans</td>
<td>siteId、page (number)、pageSize (number)</td>
<td>获取该站点的所有数据保护计划</td>
</tr>
<tr class="odd">
<td>getCustomerDataProtectionPlans</td>
<td>page (number)、pageSize (number)</td>
<td>获取该用户的所有数据保护计划</td>
</tr>
<tr class="even">
<td>getCustomerExecutionHistory</td>
<td>siteId、page (number)、pageSize (number)</td>
<td>获取该用户的所有作业的历史记录和状态（可以通过 siteId 进行筛选）</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanExecutionHistory</td>
<td>siteId、jobId、page (number)、pageSize (number)</td>
<td>获取特定作业的所有运行的历史记录和状态</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanDetails</td>
<td>siteId、jobId、includeSettings (boolean)</td>
<td>获取特定数据保护作业的所有详细信息</td>
</tr>
<tr class="odd">
<td>getExecutionById</td>
<td>siteId、jobId、executionId</td>
<td>获取特定数据保护作业运行的详细信息</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanSchedules</td>
<td>siteId、jobId</td>
<td>获取已调度的数据保护作业运行时间列表</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanScheduleDetails</td>
<td>siteId、jobId、scheduleId</td>
<td>获取已调度的数据保护作业运行的具体详细信息</td>
</tr>
<tr class="even">
<td>getNextRuns</td>
<td>siteId、jobId、limit (number)</td>
<td>获取已调度的即将进行的数据保护作业列表</td>
</tr>
<tr class="odd">
<td>getRetainedCopiesForDataProtectionPlan</td>
<td>siteId、jobId、page? (number)、pageSize? (number)</td>
<td>获取从数据保护作业创建的已存储成功备份的列表。</td>
</tr>
<tr class="even">
<td>getRetainedCopiesForSite</td>
<td>siteId、page (number)、pageSize (number)</td>
<td>获取为特定站点上的所有数据保护作业创建的已存储成功备份的列表。</td>
</tr>
<tr class="odd">
<td>getRetainedCopies</td>
<td>page (number)、pageSize (number)</td>
<td>获取为此用户创建的已存储成功备份的列表。</td>
</tr>
<tr class="even">
<td>getSiteDatabases</td>
<td>siteId</td>
<td>加载站点中用于恢复到另一个数据库的数据库列表。</td>
</tr>
<tr class="odd">
<td>getDatabaseObjects</td>
<td>siteId、xAuthCredential、objectName、objectType、search、page (number)、pageSize (number)</td>
<td>获取数据库上现有对象的列表以选择要备份的对象</td>
</tr>
<tr class="even">
<td>restoreAuthenticationCheck</td>
<td>siteId</td>
<td>检查用户是否具有对所选对象执行恢复的适当的身份验证凭据</td>
</tr>
<tr class="odd">
<td>getDRDetails</td>
<td>siteId、actionType(getTargets, getDRDetails)</td>
<td>获取站点的快照灾难恢复尝试详细信息</td>
</tr>
<tr class="even">
<td>getFailoverDetails</td>
<td>siteId、page (number)、pageSize (number)</td>
<td>获取站点的快照灾难恢复故障转移详细信息</td>
</tr>
<tr class="odd">
<td>getBackupJobObjects</td>
<td>siteId、jobId、executionId</td>
<td>获取针对特定　DSA　备份保存的对象</td>
</tr>
<tr class="even">
<td>getRestoreHistory</td>
<td>siteId、backupJobId</td>
<td>获取针对用户、特定于站点或特定备份作业的所有 DSA 备份的历史记录</td>
</tr>
<tr class="odd">
<td>getRestoreExecutions</td>
<td>siteId、jobId、executionId、restoreJobId</td>
<td>获取特定备份作业/执行的执行尝试列表</td>
</tr>
<tr class="even">
<td>getRestoreExecutionDetails</td>
<td>siteId、jobId、executionId、restoreExecutionId</td>
<td>获取 DSA 恢复的执行尝试的详细信息</td>
</tr>
</tbody>
</table>

### 突变

<table style="width:99%;">
<colgroup>
<col style="width: 25%" />
<col style="width: 37%" />
<col style="width: 37%" />
</colgroup>
<thead>
<tr class="header">
<th>突变</th>
<th>输入</th>
<th>详细信息</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>一般站点 API</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>startSqlEngine</td>
<td>siteId（SQL 引擎的站点 ID）</td>
<td>针对给定站点 ID 启动 SQL 引擎。</td>
</tr>
<tr class="odd">
<td>stopSqlEngine</td>
<td>siteId（SQL 引擎的站点 ID）</td>
<td>针对给定站点 ID 停止 SQL 引擎。</td>
</tr>
<tr class="even">
<td>scaleOutInSqlEngine</td>
<td>siteId（SQL 引擎的站点 ID）、nodeCount（要纵向扩展/缩减的节点数量）</td>
<td>将 SQL 引擎横向扩展或缩减为针对给定站点 ID 提供的节点数。</td>
</tr>
<tr class="odd">
<td>scaleUpDownSqlEngine</td>
<td>siteId（SQL 引擎的站点 ID）、instanceType（要更改到的节点实例类型）</td>
<td>将 SQL 引擎纵向扩展或缩减为针对给定站点 ID 提供的实例类型。</td>
</tr>
<tr class="even">
<td>storageResizeSqlEngine</td>
<td>siteId（SQL 引擎的站点 ID）、value（新存储大小值）、units（存储大小单位）</td>
<td>将 SQL 引擎的存储大小调整为提供的以 units 为单位的总值。</td>
</tr>
<tr class="odd">
<td>startMlEngine</td>
<td>siteId（ML 引擎的站点 ID）</td>
<td>针对给定站点 ID 启动 ML 引擎。</td>
</tr>
<tr class="even">
<td>stopMlEngine</td>
<td>siteId（ML 引擎的站点 ID）</td>
<td>针对给定站点 ID 停止 ML 引擎。</td>
</tr>
<tr class="odd">
<td>addPrivateLinkUsers</td>
<td>id、siteId、users（用户列表）</td>
<td>将 privatelink 用户添加到专用链接连接的允许列表</td>
</tr>
<tr class="even">
<td>removePrivateLinkUsers</td>
<td>id、siteId、users（用户列表）</td>
<td>从专用链接连接的允许列表中移除 privatelink 用户</td>
</tr>
<tr class="odd">
<td><strong>系统 API</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>assumeRole</td>
<td>targetRole (ROLE)</td>
<td>更改/承担您用户的角色。</td>
</tr>
<tr class="odd">
<td>createAlert</td>
<td>alert ()</td>
<td>创建阈值警报</td>
</tr>
<tr class="even">
<td>updateAlert</td>
<td>alertId、alert ()</td>
<td>更新阈值警报</td>
</tr>
<tr class="odd">
<td>deleteAlerts</td>
<td>alertIds</td>
<td>按 ID 列表删除多个警报</td>
</tr>
<tr class="even">
<td>toggleGlobalNotification</td>
<td>updatedSubscription(email, topicName, channelName)</td>
<td>为您的用户订阅通知主题</td>
</tr>
<tr class="odd">
<td>createSandbox</td>
<td>name、parentSiteId (siteId)</td>
<td>创建站点的沙盒副本</td>
</tr>
<tr class="even">
<td>deleteSandbox</td>
<td>sandboxId</td>
<td>请求删除沙盒</td>
</tr>
<tr class="odd">
<td><strong>数据保护、备份和恢复作业</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>createDataProtectionPlan</td>
<td>siteId、createInput (name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism (DSA, CDP,</td>
<td>DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects(objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName, objectType,))</td>
</tr>
<tr class="odd">
<td>targetRetentionCopiesCount (number), backupType(FULL, SNAPSHOT, SNAPSHOT_DR))</td>
<td>创建站点的数据保护计划</td>
<td></td>
</tr>
<tr class="even">
<td>updateDataProtectionSettings</td>
<td>siteId、jobId、updateInput (name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism</td>
<td>(DSA, CDP, DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects(objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName, objectType))</td>
</tr>
<tr class="odd">
<td>targetRetentionCopiesCount (number), backupType(FULL, SNAPSHOT, SNAPSHOT_DR))</td>
<td>更新站点的数据保护计划</td>
<td></td>
</tr>
<tr class="even">
<td>deleteDataProtectionPlan</td>
<td>siteId、jobId</td>
<td>删除数据保护计划</td>
</tr>
<tr class="odd">
<td>createDataProtectionPlanSchedule</td>
<td>siteId、jobId、scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>创建数据保护计划的调度</td>
</tr>
<tr class="even">
<td>updateDataProtectionPlanSchedule</td>
<td>siteId、jobId、scheduleId、scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>更新数据保护计划的调度</td>
</tr>
<tr class="odd">
<td>deleteDataProtectionPlanSchedule</td>
<td>siteId、jobId、scheduleId</td>
<td>删除数据保护计划的调度</td>
</tr>
<tr class="even">
<td>previewDataProtectionPlanSchedule</td>
<td>siteId、jobId、scheduleInput (scheduleExpression, runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR))</td>
<td>预览数据保护计划的调度</td>
</tr>
<tr class="odd">
<td>abortJob</td>
<td>siteId、jobId</td>
<td>中止正在运行的数据保护计划</td>
</tr>
<tr class="even">
<td>instantJobRun</td>
<td>siteId、jobId、runType (FULL, DELTA, SNAPSHOT, SNAPSHOT_DR)</td>
<td>立即运行数据保护计划</td>
</tr>
<tr class="odd">
<td>restoreData</td>
<td>siteId、executionId、jobId、settings (name, abortOnAccessRightsViolation (boolean), runAsCopyJob (boolean), restoreToDifferentDb (boolean), renameRestoredObjects (boolean),</td>
<td>skipStatistics (boolean), skipJoinHashIndexes (boolean), targetDatabase, tableNameSuffix, objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects (objectName,</td>
</tr>
<tr class="even">
<td>updateRestoreJobSettings</td>
<td>siteId、jobId、backupExecutionId、updateInput(name, abortOnAccessRightsViolation (boolean), runAsCopyJob (boolean), restoreToDifferentDb (boolean), renameRestoredObjects</td>
<td>(boolean), skipStatistics (boolean), skipJoinHashIndexes (boolean), targetDatabase, tableNameSuffix, objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects</td>
</tr>
<tr class="odd">
<td>failOverData</td>
<td>siteId、executionId、jobId、failOverInput ( name, sourceSite, targetSite, description, active (boolean), priority (number), jobType (BACKUP, RESTORE, REPLICATION), backupMechanism</td>
<td>(DSA’,CDP, DSC), retainedCopiesCount (number), autoAbort (boolean), autoAbortInMinutes (number), objects (objectName, objectType, parentName, parentType, includeAll (boolean), excludeObjects</td>
</tr>
<tr class="even">
<td>precheckRestore</td>
<td>siteId、executionId、jobId</td>
<td>（针对给定站点（如有提供））验证快照能否用作恢复副本</td>
</tr>
<tr class="odd">
<td>protectRetainCopy</td>
<td>siteId、jobId、backupSetId、isRetained (boolean)</td>
<td>保护或取消保护保留的副本</td>
</tr>
</tbody>
</table>

错误处理
--------

与 REST API 类似，调用 GraphQL API 也可以返回错误响应。一些示例包括未经授权/禁止的错误、未找到资源、操作失败等。GraphQL API 调用产生的错误详细信息包含在返回的响应正文中。

由于 GraphQL 调用可以跨越多个服务，因此错误对象将作为响应正文 `errors` 部分的列表返回。错误对象的结构如下所示：

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

错误代码包含在错误对象 `extensions` 部分中名为 `code` 的字段中。

### 未经授权的响应示例

对未经授权的 API 调用的响应。

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

### 未找到请求响应的示例

正在试图获取不存在的站点的详细信息。

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

### 无效请求响应的示例

在 SQL 引擎启动操作当前不可用的站点上调用该操作（例如 SQL 引擎已经在运行）。

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

GraphQL 客户端库
----------------

下面的列表包含了用于调用 GraphQL API 的热门客户端库：

[GraphQL 客户端](https://graphql.org/code/#graphql-clients)
