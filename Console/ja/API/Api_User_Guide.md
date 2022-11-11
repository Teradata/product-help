管理コンソールGraphQL API
=========================

目次
----

-   [はじめに](#Getting-Started)
-   [概要](#概要)
-   [GraphQLについて](#About-Graphql)
-   [GraphQL APIエンドポイント](#The-GraphQL-API-Endpoint)
-   [GraphQL APIの呼び出し](#Calling-the-GraphQL-API)
    -   [認証](#認証)
    -   [リクエスト本文](#Request-Body)
    -   [API呼び出しの例](#Example-API-Call)
-   [サポートされるQueryとMutation](#Supported-Queries-and-Mutations)
    -   [Query](#Query)
    -   [Mutation](#Mutation)
-   [エラー処理](#Error-Handling)
-   [GraphQLクライアント ライブラリ](#GraphQL-Client-Libraries)

はじめに
--------

このセクションでは、管理コンソールのパブリックAPIを使用した実践例とともに、実際の稼働をすぐに始めるために役立つ実践チュートリアルについて説明します。

-   [Postmanチュートリアル](./appendix/postman/tutorial.md)
-   [NodeJSチュートリアル](./appendix/nodejs/tutorial.md)
-   [Pythonチュートリアル](./appendix/python/tutorial.md)

概要
----

Vantage Console(VC)API for VantageCloud Enterpriseによって、データベースの一般的なエラスティシティ操作にプログラマティックにアクセスできるようになります。この新しいAPIの登場により、VantageCloud Enterpriseの承認済みユーザーは、カスタムのスクリプト/アプリ(クライアント)を作成してTeradataシステムを直接管理できるようになりました。例えば、管理者はVCパブリックAPIを使用して、サイトのSQLエンジンを使用要件に応じて起動/停止することでコストを管理できます。

GraphQLについて
---------------

GraphQLはAPIのクエリ言語で、以下を行ないます。

-   強く[型付けされたスキーマ](https://graphql.org/learn/schema/)によりAPI機能を記述します。
    -   すべてのエントリポイント(Query/Mutation)を記述するtypeスキーマおよび返されるデータのスキーマを通じて、APIのサポートされる機能を学習します。
    -   GraphQLスキーマは、GraphQLのスキーマ定義言語(SDL)により定義されます。
-   クライアントが[QueryおよびMutation](https://graphql.org/learn/queries/)を使用して必要なものをリクエストすることを許可します。
    -   GraphQL API呼び出しにより、リクエストされたものが正確に(過不足なく)返されます。
    -   クライアントは要求したデータを制御します。

正規のGraphQL仕様については、[こちら](https://graphql.github.io/graphql-spec/June2018/)を参照してください。

GraphQL APIエンドポイント
-------------------------

-   Teradata Vantageユーザーの認証情報による認証。
-   GraphQL VCパブリックAPIのエンドポイントは以下のとおりです。`https://api.cloud.vantage.teradata.com/graphql/`
-   GraphQLスキーマ定義言語(SDL)は以下からダウンロードできます: `https://api.cloud.vantage.teradata.com/graphql/sdl`
    -   SDLをクライアントにインポートすることで、カスタムのquery/mutationを構築できます。

GraphQL APIの呼び出し
---------------------

GraphQL APIはHTTPエンドポイントで、REST APIと似ています。相違点は、リクエストの内容(GraphQL仕様 - SDL)と、REST APIのエンドポイントパス、ヘッダー、リクエスト本文との間にあります。GraphQLエンドポイント(クエリまたはMutation)への呼び出しは、すべて`POST`HTTPメソッドを使用します。

### 認証

VC GraphQL APIのセキュリティは基本認証によって確保されます([RFC 7617](https://tools.ietf.org/html/rfc7617)を参照)。このAPIへの呼び出しを行なうには(任意のGraphQL QueryまたはMutation)、以下の`Authorization`ヘッダーが必要になります。

``` sourceCode
{
...
"Authorization": "Basic <base64 encoded username:password>"
...
}
```

### リクエスト本文

リクエスト本文のフォーマット

``` sourceCode
{
  "operationName":"myOperationName",
  "query":"query myOperationName {...}"
}
```

### cURLを使用したAPI呼び出しの例

以下に、cURLを使用したSQLエンジン停止呼び出し(Mutation)の例を示します。詳しいチュートリアルおよび例については、上記の[はじめに](#Getting-Started)セクションを参照してください。

``` sourceCode
curl 'https://api.cloud.vantage.teradata.com/graphql' -H 'authorization: Basic <base64 encoded username:password>' -H 'content-type: application/json' --data-binary '{"operationName":"stopSqlEngine","variables":{},"query":"mutation stopSqlEngine { stopSqlEngine(siteId: \"TDICA01780PRD00\") {id, name, status, startTime, endTime, details }}"}'
```

サポートされるQueryおよびMutation(部分的なリスト)
-------------------------------------------------

### Query

<table style="width:99%;">
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr class="header">
<th>Query</th>
<th>入力</th>
<th>詳細</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>一般的なサイトAPI</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>api</td>
<td>n/a</td>
<td>APIバージョン詳細</td>
</tr>
<tr class="odd">
<td>user</td>
<td>n/a</td>
<td>ユーザーのポリシー ロールを取得</td>
</tr>
<tr class="even">
<td>sites</td>
<td>n/a</td>
<td>Teradataサイトを一覧表示</td>
</tr>
<tr class="odd">
<td>site</td>
<td>id(サイトID)</td>
<td>特定サイトの詳細を取得</td>
</tr>
<tr class="even">
<td>sqlEngine</td>
<td>siteId</td>
<td>所定のサイトIDについて特定のSQLエンジンに関する詳細を取得</td>
</tr>
<tr class="odd">
<td>getSqlEngineOperation</td>
<td>siteId、operationId</td>
<td>特定のSQLエンジンの動作に関する詳細を取得</td>
</tr>
<tr class="even">
<td>mlEngine</td>
<td>siteId</td>
<td>所定のサイトIDについて特定のMLエンジンに関する詳細を取得</td>
</tr>
<tr class="odd">
<td>getMlEngineOperation</td>
<td>siteId、operationId</td>
<td>特定のMLエンジンの動作に関する詳細を取得</td>
</tr>
<tr class="even">
<td>privateLink</td>
<td>siteId</td>
<td>サイトについてのプライベート リンク情報を取得</td>
</tr>
<tr class="odd">
<td><strong>システムAPI</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSystemUsage</td>
<td>usageQuery(siteId、startTime、endTime、namespace、dataPoints)</td>
<td>サイトの利用データを取得</td>
</tr>
<tr class="odd">
<td>getNotifications</td>
<td>lastSeenNotificationTimestamp、lastEvaluatedKey(notificationId、userId、receivedTimestamp)</td>
<td>ユーザーのグローバル通知を取得</td>
</tr>
<tr class="even">
<td>getNotificationSettings</td>
<td>receivedTimestamp</td>
<td>ユーザーのグローバル メール通知の設定を取得</td>
</tr>
<tr class="odd">
<td>getAlerts</td>
<td>alertParams(site_id、activity_type、engine_types、dept_id)</td>
<td>このユーザーのしきい値アラームの全リストまたはフィルタ処理済みリストを取得</td>
</tr>
<tr class="even">
<td>sandboxes</td>
<td></td>
<td>このユーザーのすべてのサンドボックスを取得</td>
</tr>
<tr class="odd">
<td>sandbox</td>
<td>sandboxId</td>
<td>サンドボックスについての情報を取得</td>
</tr>
<tr class="even">
<td><strong>Consumption Monitoring</strong></td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>getVantageUnits</td>
<td>aggregatesQuery</td>
<td>Vantage Consumption Monitoringが有効なサイトのVantage単位数使用データを取得</td>
</tr>
<tr class="even">
<td>getCDSUsage</td>
<td>aggregatesQuery</td>
<td>Vantage Consumption Monitoringが有効なサイトの消費データ ストレージ データを取得</td>
</tr>
<tr class="odd">
<td>getQueryActivity</td>
<td>aggregatesQuery</td>
<td>Vantage Consumption Monitoringが有効なサイトのVantageクエリのアクティビティおよび使用データを取得</td>
</tr>
<tr class="even">
<td>getWeeklyStats</td>
<td>aggregatesQuery</td>
<td>Vantage Consumption Monitoringが有効なサイトのVantageクエリのデータを取得</td>
</tr>
<tr class="odd">
<td>getTokenUnits</td>
<td>aggregatesQuery</td>
<td>Unit Consumption Monitoringが有効なサイトの単位数消費データを取得</td>
</tr>
<tr class="even">
<td>getTokenStorage</td>
<td>aggregatesQuery</td>
<td>Unit Consumption Monitoringが有効なサイトの単位数消費ストレージ データを取得</td>
</tr>
<tr class="odd">
<td><em>aggregatesQuery(interval_type、activity_type(STORAGE、UNITS、VANTAGE_UNITS、CDS)、site_id、engine_types、range_begin、range_end、grouping、dept_id)</em></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getForecast</td>
<td>siteId、numOfDays</td>
<td>Vantage Consumption Monitoringが有効なサイトのVantage単位数使用予測データを取得</td>
</tr>
<tr class="odd">
<td>getContracts</td>
<td>siteId</td>
<td>Vantage Consumption Monitoringが有効なサイトの問い合わせ先データを取得</td>
</tr>
<tr class="even">
<td>getTokenContracts</td>
<td>siteId</td>
<td>Unit Consumption Monitoringが有効なサイトの問い合わせ先データを取得</td>
</tr>
<tr class="odd">
<td><strong>データ保護、バックアップ、回復ジョブ</strong>s</td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>getSiteDataProtectionPlans</td>
<td>siteId、page (number)、pageSize (number)</td>
<td>このサイトのデータ保護計画をすべて取得</td>
</tr>
<tr class="odd">
<td>getCustomerDataProtectionPlans</td>
<td>page (number)、pageSize (number)</td>
<td>このユーザーのデータ保護計画をすべて取得</td>
</tr>
<tr class="even">
<td>getCustomerExecutionHistory</td>
<td>siteId、page (number)、pageSize (number)</td>
<td>このユーザーのすべてのジョブの履歴とステータスを取得(siteIdによりフィルタリング可能)</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanExecutionHistory</td>
<td>siteId、jobId、page (number)、pageSize (number)</td>
<td>特定ジョブのすべての実行の履歴とステータスを取得</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanDetails</td>
<td>siteId、jobId、includeSettings (boolean)</td>
<td>特定のデータ保護ジョブの詳細をすべて取得</td>
</tr>
<tr class="odd">
<td>getExecutionById</td>
<td>siteId、jobId、executionId</td>
<td>特定のデータ保護ジョブ実行の詳細を取得</td>
</tr>
<tr class="even">
<td>getDataProtectionPlanSchedules</td>
<td>siteId、jobId</td>
<td>データ保護ジョブの実行時間スケジュールのリストを取得</td>
</tr>
<tr class="odd">
<td>getDataProtectionPlanScheduleDetails</td>
<td>siteId、jobId、scheduleId</td>
<td>データ保護ジョブの実行スケジュールの特定の詳細を取得</td>
</tr>
<tr class="even">
<td>getNextRuns</td>
<td>siteId、jobId、limit (number)</td>
<td>今後のデータ保護ジョブ実行スケジュールのリストを取得</td>
</tr>
<tr class="odd">
<td>getRetainedCopiesForDataProtectionPlan</td>
<td>siteId、jobId、page? (number)、pageSize? (number)</td>
<td>データ保護ジョブで作成された保存済みの正常なバックアップのリストを取得。</td>
</tr>
<tr class="even">
<td>getRetainedCopiesForSite</td>
<td>siteId、page (number)、pageSize (number)</td>
<td>特定サイトですべてのデータ保護ジョブに作成された保存済みの正常なバックアップのリストを取得。</td>
</tr>
<tr class="odd">
<td>getRetainedCopies</td>
<td>page (number)、pageSize (number)</td>
<td>このユーザーに作成された保存済みの正常なバックアップのリストを取得。</td>
</tr>
<tr class="even">
<td>getSiteDatabases</td>
<td>siteId</td>
<td>別のデータベースへのリストア用にこのサイトのデータベースのリストをロード。</td>
</tr>
<tr class="odd">
<td>getDatabaseObjects</td>
<td>siteId、xAuthCredential、objectName、objectType、search、page (number)、pageSize (number)</td>
<td>どれをバックアップするかを選ぶために、データベース上に存在するオブジェクトのリストを取得</td>
</tr>
<tr class="even">
<td>restoreAuthenticationCheck</td>
<td>siteId</td>
<td>選択されたオブジェクトの回復を行なうための適切な認証情報がユーザーにあるかどうかをチェック</td>
</tr>
<tr class="odd">
<td>getDRDetails</td>
<td>siteId、actionType(getTargets、getDRDetails)</td>
<td>サイトの障害回復を試みた詳細のスナップショットを取得</td>
</tr>
<tr class="even">
<td>getFailoverDetails</td>
<td>siteId、page (number)、pageSize (number)</td>
<td>サイトの障害回復フェイルオーバーの詳細のスナップショットを取得</td>
</tr>
<tr class="odd">
<td>getBackupJobObjects</td>
<td>siteId、jobId、executionId</td>
<td>特定のDSAバックアップを対象にした保存済みオブジェクトを取得</td>
</tr>
<tr class="even">
<td>getRestoreHistory</td>
<td>siteId、backupJobId</td>
<td>ユーザーの、またはサイトに固有な、または特定のバックアップ ジョブの、すべてのDSAバックアップの履歴を取得</td>
</tr>
<tr class="odd">
<td>getRestoreExecutions</td>
<td>siteId、jobId, executionId、restoreJobId</td>
<td>特定のバックアップジョブ/実行の試行のリストを取得</td>
</tr>
<tr class="even">
<td>getRestoreExecutionDetails</td>
<td>siteId、jobId、executionId、restoreExecutionId</td>
<td>DSAの回復を試みた実行の詳細を取得</td>
</tr>
</tbody>
</table>

### Mutation

<table style="width:99%;">
<colgroup>
<col style="width: 25%" />
<col style="width: 37%" />
<col style="width: 37%" />
</colgroup>
<thead>
<tr class="header">
<th>Mutation</th>
<th>入力</th>
<th>詳細</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><strong>一般的なサイトAPI</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>startSqlEngine</td>
<td>siteId(SQLエンジンのサイトID)</td>
<td>所定のサイトIDのSQLエンジンを起動。</td>
</tr>
<tr class="odd">
<td>stopSqlEngine</td>
<td>siteId(SQLエンジンのサイトID)</td>
<td>所定のサイトIDのSQLエンジンを停止。</td>
</tr>
<tr class="even">
<td>scaleOutInSqlEngine</td>
<td>siteId(SQLエンジンのサイトID)、nodeCount(スケール アップ/ダウンするノードの数)</td>
<td>所定のサイトIDについて、SQLエンジンを指定のノード数にスケール アウトまたはスケール イン。</td>
</tr>
<tr class="odd">
<td>scaleUpDownSqlEngine</td>
<td>siteId(SQLエンジンのサイトID)、instanceType(このノード インスタンス タイプに変更)</td>
<td>所定のサイトIDについて、SQLエンジンを指定のインスタン スタイプにスケール アップまたはスケール ダウン。</td>
</tr>
<tr class="even">
<td>storageResizeSqlEngine</td>
<td>siteId(SQLエンジンのサイトID)、値(新しいストレージ サイズ値)、単位数(ストレージ サイズ単位数)</td>
<td>指定の合計値(単位数)へのSQLエンジンのストレージ サイズ変更。</td>
</tr>
<tr class="odd">
<td>startMlEngine</td>
<td>siteId(MLエンジンのサイトID)</td>
<td>所定のサイトIDのMLエンジンを起動。</td>
</tr>
<tr class="even">
<td>stopMlEngine</td>
<td>siteId(MLエンジンのサイトID)</td>
<td>所定のサイトIDのMLエンジンを停止。</td>
</tr>
<tr class="odd">
<td>addPrivateLinkUsers</td>
<td>id、siteId、users(ユーザーのリスト)</td>
<td>プライベート リンクのユーザーをプライベート リンク接続の許可リストに追加</td>
</tr>
<tr class="even">
<td>removePrivateLinkUsers</td>
<td>id、siteId、users(ユーザーのリスト)</td>
<td>プライベート リンクのユーザーをプライベート リンク接続の許可リストから削除</td>
</tr>
<tr class="odd">
<td><strong>システムAPI</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>assumeRole</td>
<td>targetRole(ROLE)</td>
<td>ユーザーのロールを変更/担当。</td>
</tr>
<tr class="odd">
<td>createAlert</td>
<td>alert()</td>
<td>しきい値アラームを作成</td>
</tr>
<tr class="even">
<td>updateAlert</td>
<td>alertId、alert()</td>
<td>しきい値アラームを更新</td>
</tr>
<tr class="odd">
<td>deleteAlerts</td>
<td>alertIds</td>
<td>IDのリストにより複数のアラームを削除</td>
</tr>
<tr class="even">
<td>toggleGlobalNotification</td>
<td>updatedSubscription(email、topicName、channelName)</td>
<td>ユーザーを通知トピックに登録</td>
</tr>
<tr class="odd">
<td>createSandbox</td>
<td>name、parentSiteId(siteId)</td>
<td>サイトのサンドボックス コピーを作成</td>
</tr>
<tr class="even">
<td>deleteSandbox</td>
<td>sandboxId</td>
<td>サンドボックスを削除するようにリクエスト</td>
</tr>
<tr class="odd">
<td><strong>データ保護ジョブ、バックアップ ジョブ、回復ジョブ</strong></td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>createDataProtectionPlan</td>
<td>siteId、createInput(name、sourceSite、targetSite、description、active (boolean)、priority (number)、jobType(BACKUP、RESTORE、REPLICATION)、backupMechanism(DSA、CDP、</td>
<td>DSC)、retainedCopiesCount (number)、autoAbort (boolean)、autoAbortInMinutes (number)、objects(objectName、objectType、parentName、parentType、includeAll (boolean)、excludeObjects(objectName、objectType,))</td>
</tr>
<tr class="odd">
<td>targetRetentionCopiesCount (number)、backupType(FULL、SNAPSHOT、SNAPSHOT_DR))</td>
<td>サイトのデータ保護計画を作成</td>
<td></td>
</tr>
<tr class="even">
<td>updateDataProtectionSettings</td>
<td>siteId、jobId、updateInput(name、sourceSite、targetSite、description、active (boolean)、priority (number)、jobType(BACKUP、RESTORE、REPLICATION)、backupMechanism</td>
<td>(DSA、CDP、DSC)、retainedCopiesCount (number)、autoAbort (boolean)、autoAbortInMinutes (number)、objects(objectName、objectType、parentName、parentType、includeAll (boolean)、excludeObjects(objectName、objectType))</td>
</tr>
<tr class="odd">
<td>targetRetentionCopiesCount (number)、backupType(FULL、SNAPSHOT、SNAPSHOT_DR))</td>
<td>サイトのデータ保護計画を更新</td>
<td></td>
</tr>
<tr class="even">
<td>deleteDataProtectionPlan</td>
<td>siteId、jobId</td>
<td>データ保護計画を削除</td>
</tr>
<tr class="odd">
<td>createDataProtectionPlanSchedule</td>
<td>siteId、jobId、scheduleInput(scheduleExpression、runType(FULL、DELTA、SNAPSHOT、SNAPSHOT_DR))</td>
<td>データ保護計画のスケジュールを作成</td>
</tr>
<tr class="even">
<td>updateDataProtectionPlanSchedule</td>
<td>siteId、jobId、scheduleId、scheduleInput(scheduleExpression、runType(FULL、DELTA、SNAPSHOT、SNAPSHOT_DR))</td>
<td>データ保護計画のスケジュールを更新</td>
</tr>
<tr class="odd">
<td>deleteDataProtectionPlanSchedule</td>
<td>siteId、jobId、scheduleId</td>
<td>データ保護計画のスケジュールを削除</td>
</tr>
<tr class="even">
<td>previewDataProtectionPlanSchedule</td>
<td>siteId、jobId、scheduleInput(scheduleExpression、runType(FULL、DELTA、SNAPSHOT、SNAPSHOT_DR))</td>
<td>データ保護計画のスケジュールをプレビュー</td>
</tr>
<tr class="odd">
<td>abortJob</td>
<td>siteId、jobId</td>
<td>データ保護計画の実行を中断</td>
</tr>
<tr class="even">
<td>instantJobRun</td>
<td>siteId、jobId、runType(FULL、DELTA、SNAPSHOT、SNAPSHOT_DR)</td>
<td>データ保護計画を今すぐ実行</td>
</tr>
<tr class="odd">
<td>restoreData</td>
<td>siteId、executionId、jobId、settings(名前、abortOnAccessRightsViolation (boolean)、runAsCopyJob (boolean)、restoreToDifferentDb (boolean)、renameRestoredObjects (boolean)、</td>
<td>skipStatistics (boolean)、skipJoinHashIndexes (boolean)、targetDatabase、tableNameSuffix、objects(objectName、objectType、parentName、parentType、includeAll (boolean)、excludeObjects(objectName、</td>
</tr>
<tr class="even">
<td>updateRestoreJobSettings</td>
<td>siteId、jobId、backupExecutionId、updateInput(名前、abortOnAccessRightsViolation (boolean)、runAsCopyJob (boolean)、restoreToDifferentDb (boolean)、renameRestoredObjects</td>
<td>(boolean)、skipStatistics (boolean)、skipJoinHashIndexes (boolean)、targetDatabase、tableNameSuffix、objects(objectName、objectType、parentName、parentType、includeAll (boolean)、excludeObjects</td>
</tr>
<tr class="odd">
<td>failOverData</td>
<td>siteId、executionId、jobId、failOverInput(名前、sourceSite、targetSite、description、active (boolean)、priority (number)、jobType(BACKUP、RESTORE、REPLICATION)、backupMechanism</td>
<td>(DSA’、CDP、DSC)、retainedCopiesCount (number)、autoAbort (boolean)、autoAbortInMinutes (number)、objects(objectName、objectType、parentName、parentType、includeAll (boolean)、excludeObjects</td>
</tr>
<tr class="even">
<td>precheckRestore</td>
<td>siteId、executionId、jobId</td>
<td>スナップショットを(提供される場合に所定のサイトで)回復コピーとして使用できるかどうかを検証</td>
</tr>
<tr class="odd">
<td>protectRetainCopy</td>
<td>siteId、jobId、backupSetId、isRetained (boolean)</td>
<td>保存されたコピーを保護または保護解除</td>
</tr>
</tbody>
</table>

エラー処理
----------

REST APIのように、GraphQL APIへの呼び出しもエラー応答が返される場合があります。例としては、未承認/禁則エラー、リソース未検出、操作の失敗などがあります。GraphQL API呼び出しによるエラーの詳細は、返された応答本文に含まれています。

GraphQL呼び出しは複数のサービスに及ぶ場合もあるので、エラー オブジェクトは応答本文の`errors`部分のリストとして返されます。エラー オブジェクトの構造は、以下のとおりです。

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

エラー コードは、`extensions`という名前のフィールドでエラー オブジェクトの`code`部分に含まれています。

### 未承認の応答の例

未承認のAPI呼び出しに対する応答。

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

### 未検出のリクエスト応答の例

存在しないサイトの詳細を取得しようとする試み。

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

### 無効なリクエスト応答の例

現時点でSQLエンジン起動動作を利用できないサイトでのSQLエンジン起動動作呼び出し(例: SQLエンジンがすでに実行している場合)。

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

GraphQLクライアント ライブラリ
------------------------------

以下のリストには、GraphQL APIの呼び出しによく使われるクライアント ライブラリが含まれています。

[GraphQLクライアント](https://graphql.org/code/#graphql-clients)
