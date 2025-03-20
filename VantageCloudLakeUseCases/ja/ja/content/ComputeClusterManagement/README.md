SQLによるコンピューティング クラスタ管理
----------------------------------------

### 始める前に

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

### はじめに

このユース ケースでは、SQLを使用してコンピューティング リソースを作成および管理するプロセスについて説明します。また、これらのタスクの多くは、 VantageCloud Lake Console UIを使用して実行することもできます。

### セットアップ

このユース ケースには、次の権限が必要です。必要に応じて、「dbc」などの管理ユーザーでエディターに接続し、このユース ケースを実行するデータベース ユーザーにこれらの権限を付与します。

``` sourceCode
GRANT CREATE COMPUTE GROUP TO "${username}" WITH GRANT OPTION;
GRANT DROP COMPUTE GROUP TO "${username}" WITH GRANT OPTION;

GRANT CREATE ROLE TO "${username}" WITH GRANT OPTION;
GRANT DROP ROLE TO "${username}" WITH GRANT OPTION;

GRANT CREATE COMPUTE PROFILE TO "${username}" WITH GRANT OPTION;
GRANT DROP COMPUTE PROFILE TO "${username}" WITH GRANT OPTION;

GRANT SELECT ON DBC.ComputeGroupsV TO "${username}";
GRANT SELECT ON DBC.ComputeProfilesV TO "${username}";
GRANT SELECT ON DBC.ComputeStatusV TO "${username}";
GRANT SELECT ON DBC.ComputeMaps TO "${username}";
GRANT SELECT ON DBC.ComputeMapsV TO "${username}";
```

### コンピューティング グループを作成する

この演習では、架空の研究プロジェクト用のコンピューティング リソースを作成しましょう。コンピューティング グループは、ビジネス グループ、アプリケーション、またはその他のユーザー グループを、ワークロードの処理に使用できる柔軟なコンピューティング リソースに関連付けるために使用されます。各コンピューティング グループには、コンピューティング リソースの1つ以上のクラスタが含まれており、各クラスタはコンピューティング プロファイルと呼ばれます。

QUERY\_STRATEGY引数は、関連付けられたコンピューティング グループで実行されるワークロードの種類を定義します。STANDARD(通常のクエリー操作)またはANALYTIC(高度な分析、AI/ ML、またはOpen Analytics Frameworkコンテナ)のいずれかです。

``` sourceCode
CREATE COMPUTE GROUP Research_Group USING QUERY_STRATEGY ('STANDARD');
```

### プロジェクトのロールを作成する

ロール-ベースのアクセス制御を使用すると、ユーザー権限の管理が容易になります。ここでは、次の2つのロールを作成します。 \* コンピューティング リソースとそれらにアクセスできるユーザーを管理する権限を持つ管理者ロール \* コンピューティング グループ リソースへのアクセスを許可するユーザー ロール

``` sourceCode
-- Create an admin role for the project
CREATE ROLE Research_Admin_Role;
GRANT CREATE COMPUTE GROUP TO Research_Admin_Role;
GRANT DROP COMPUTE GROUP TO Research_Admin_Role;

-- Create the user role for the project
CREATE ROLE Research_Role;
GRANT COMPUTE GROUP Research_Group TO Research_Role;
```

### ユーザーとコンピューティング グループ リソースに関連付ける

ユーザー クエリーは、コンピューティング グループへのデフォルトの関連付けを設定するか、セッションごとに関連付けを設定することで、コンピューティング リソースにアクセスできます。どちらの場合も、ユーザーにはコンピューティング グループに対する権限が必要です。権限は直接割り当てることも、ロール-ベースのアクセスを介して割り当てることもできます。

次のSQLは以下の方法を示しています。 \* デフォルトのコンピュートグループを持つユーザーを作成する方法 \* ユーザーをデフォルトのコンピュートグループに変更する方法 \* ユーザーにさまざまなロールを付与する方法 \* ユーザーがセッションごとにコンピュートグループを設定する方法

``` sourceCode
-- Create a new user
CREATE USER "${USER}" AS 
PASSWORD = "${PASSWORD}"
PERM=1e8
DEFAULT DATABASE = "${USER}"
COMPUTE GROUP = Research_Group;

-- Provide default Compute Cluster resources to an existing user
MODIFY USER "${USER}" AS COMPUTE GROUP = Research_Group;

-- Also provide access to the Compute Cluster resources
GRANT Research_Role TO "${USER}";

-- This user also can administer the resources
GRANT Research_Admin_Role TO "${USER}";

-- User can set access to any specific group that they have access
SET SESSION COMPUTE GROUP Research_Group;
```

### グループにコンピューティング リソースを割り当てる

コンピューティング グループには、1つ以上のコンピューティング プロファイルが含まれます。アクティブになるのは、常にそのうちの1つだけです。コンピューティング プロファイルは、クエリー ワークロードの処理に使用できるコンピューティング リソースと関連パラメータを記述します。各コンピューティング プロファイルには、次の内容が記述されます。 \* クラスタ サイズ (「XSmall」(1ノード) から XXLarge (64ノード)) \* プロファイルがスケーリングできるエラスティック クラスタ インスタンスの最小数と最大数を定義するスケーリング ポリシー。各インスタンスは、選択したサイズ (XSmall、Medium、Largeなど)のクラスタを表します。 \* crontab形式の開始時刻と終了時刻。このスケジュール機能により、グループで使用できるコンピューティング プロファイルを常にきめ細かく制御できます。 \* クラスタがシャットダウンする前にクエリーを完了する必要がある時間を定義するクールダウン期間 \* initial\_suspended - ユーザーがコンピューティング クラスタを作成した後、そのクラスタを休止状態にするかどうか。コンピューティング プロファイルは、SQLまたはConsole UIを使用して手動で一時停止または再開できます。

``` sourceCode
-- View existing maps for available Compute Cluster sizes
SELECT * FROM DBC.ComputeMapsV ORDER BY NodeCount;

-- Provide resources for group
-- $MIN = 1
-- $MAX = MIN to X
-- $COOLDOWN = 1 to Y minutes
-- Create Compute Clusters where X=2 and Y=30 minutes

CREATE COMPUTE PROFILE Research_Resources
IN Research_Group, INSTANCE = TD_COMPUTE_SMALL
USING
MIN_COMPUTE_COUNT  ( 1 ) MAX_COMPUTE_COUNT  ( 2 ) SCALING_POLICY  ('STANDARD') INSTANCE_TYPE  ('STANDARD') 
INITIALLY_SUSPENDED  ('FALSE') START_TIME  ('') END_TIME  ('') COOLDOWN_PERIOD  ( 30 );
```

### 追加のクエリー

``` sourceCode
-- View existing maps for available Compute Cluster sizes
SELECT * FROM DBC.ComputeMaps ORDER BY NodeCount;

-- Display Compute Cluster Group Compute Cluster Policies
SELECT * FROM DBC.ComputeGroupsV;

-- Similar to the DBC.ComputeGroupsV view but it displays Compute Cluster group details for Compute Cluster groups to which the user has access
SELECT * FROM DBC.ComputeGroupsVX;

-- Provide Compute Cluster state information
SELECT * FROM DBC.ComputeProfilesV;

-- Similar to the DBC.COMPUTE GROUP view but it displays Compute Cluster profile details for Compute Cluster profiles to which the user has access.
SELECT * FROM DBC.ComputeStatusV;
```

### クリーンアップ

``` sourceCode
DROP ROLE Research_Admin_Role;
DROP ROLE Research_Role;
DROP COMPUTE PROFILE Research_Resources IN COMPUTE GROUP Research_Group;
DROP COMPUTE GROUP Research_Group;
```
