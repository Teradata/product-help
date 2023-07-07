SQLによるコンピューティング クラスタ管理
----------------------------------------

### 始める前に

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

### はじめに

このユース ケースでは、SQLを使用したVantageCloud Lakeでのコンピューティング クラスタの管理について解説します。

***ヒント**:独自のコンピューティング クラスタ グループを作成する用意ができたら、エディタまたはVantage Console UIでSQLを使用できます。*

### セットアップ

このユース ケースには以下の権限が必要です。

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

### 新しいリサーチ プロジェクト用のリソース グループを作成する

コンピューティング クラスタ グループは、1つ以上のコンピューティング クラスタを含んでいます。また、ユーザーのクエリーに対してユーザーとリソースを関連付けるために使用されます。

クエリー+戦略のポリシーが今後の使用のために提供されます。

``` sourceCode
CREATE COMPUTE GROUP Research_Group USING QUERY_STRATEGY ('STANDARD');
```

### プロジェクトのロールを作成する

以下の2つのロールが提供されます。\* 管理者ロール。コンピューティング クラスタ グループとグループ内のユーザーを管理します \* ユーザー ロール。コンピューティング クラスタ リソースへのアクセスを許可します

``` sourceCode
-- Create an admin role for the project
CREATE ROLE Research_Admin_Role;
GRANT CREATE COMPUTE GROUP TO Research_Admin_Role;
GRANT DROP COMPUTE GROUP TO Research_Admin_Role;

-- Create the user role for the project
CREATE ROLE Research_Role;
GRANT COMPUTE GROUP Research_Group TO Research_Role;
```

### ユーザーとコンピューティング クラスタ リソースを関連付ける

ユーザーをコンピューティング クラスタ グループに関連付けることにより、ユーザーはコンピューティング クラスタ リソースにアクセスできます。デフォルトの関連性を持つようにユーザーを作成または編集できます。ユーザーはアクセス権が与えられ、それを直接設定できます。

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

-- This user also can administrate the resources
GRANT Research_Admin_Role TO "${USER}";

-- User can set access to any specific group that they have access
SET SESSION COMPUTE GROUP Research_Group;
```

### グループにリソースを割り当てる

コンピューティング クラスタ プロファイルには、リソースのポリシーが記述されています。コンピューティング クラスタには、MINおよびMAXを使用して定義された1つ以上のインスタンスが含まれています。MINは、インスタンスまたはランクの常に利用可能な個数を表します。MAXは、使用可能なインスタンスのエラスティック部分を表します。個々のインスタンスは、EC2インスタンスなどのVMノードの数を表します。VMノードの数は、Small、Medium、またはLargeなどのインスタンス サイズ記述子によって制御されます。それぞれのサイズには、1つ前のサイズに対して2倍のVMノード数があり、2、4、8、16のようになります。ポリシーに対して指定できるオプションが他にもあります。\* initially\_suspendedは、設定後にユーザーが手動でコンピューティング クラスタを復元するまでコンピューティング クラスタをハイバネーション状態にします \* コンピューティング クラスタが処理可能になる時点の開始および終了時間を、cron tab形式を使用して指定できます \* cooldown\_periodは、終了時間後にクエリーを完了できるようにコンピューティング クラスタが実行し続ける時間の長さを指定します

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

### コンピューティング クラスタ ディクショナリにクエリーを実行しCOMPUTE CLUSTERについてのステータスを取得する

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

### コンピューティング クラスタ プロファイルを削除する

``` sourceCode
DROP ROLE Research_Admin_Role;
DROP ROLE Research_Role;
DROP COMPUTE PROFILE Research_Resources IN COMPUTE GROUP Research_Group;
DROP COMPUTE GROUP Research_Group;
```
