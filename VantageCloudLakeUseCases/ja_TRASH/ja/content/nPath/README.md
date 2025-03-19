nPathを使用したパス分析: パターンに基づく行動識別
-------------------------------------------------

### 始める前に

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

### はじめに

nPathは、大規模な順序付けられたデータに対して高速かつ柔軟な分析を実行するように設計されたSQL拡張機能です。

nPathの句を使用すると、複雑なパスクエリや順序関係を表現することができます。これらは通常、American National Standards Institute (ANSI) SQLで複数レベルの結合を記述する必要があるかもしれません。nPathを使用すると、希望する順序を指定し、その順序に沿ってデータをマッチさせるパターンを指定します。行のシーケンス内でパターンが一致するたびに、nPathは一致する行に対してSQL集約を計算します。

nPath分析では、結果につながるパスを追跡できます。例えば、顧客の行動の結果などです。

-   購買経路
-   カゴ落ち分析
-   離反経路
-   再入院などのペイシェント ジャーニー
-   不正行為につながるパス

### 通信業界の顧客移動の例

------------------------------------------------------------------------

テレコム業界では、顧客の解約(キャリア変更)への対処は大規模なコスト節約の取り組みです。nPath分析を使用すると、顧客行動に対する理解を深めリテンションを向上させる方法に焦点を当てることができます。

最初のステップとして、顧客が関与するインタラクションやトランザクションを統合したイベント テーブルを作成します。イベントをキャプチャすることで、来店、ウェブサイトへのアクセス、サポート ラインへの電話、サービスのアップグレード、サービスのキャンセルといったカスタマー ジャーニーを分析できます。

nPath分析の使用により、これらのイベントを非常に簡単な方法で分析することで、次のようなビジネス上の質問に答えるのに役立ちます。

-   顧客がウェブサイト上でどのようなパスをたどっているのか
-   顧客がサポート ラインに電話する前にどのようなパスをたどっているのか
-   顧客がサービスをキャンセルするまでにどのようなパスをたどっているのか

### エクスペリエンス

このユース ケース全体の実施所要時間は約7分です。

### セットアップ

**アセットをロード** を選択してテーブルを作成し、このユース ケースに必要なデータを自分のアカウント(Teradataデータベース インスタンス)にロードします。[アセットをロード](#data=%7B%22id%22:%22Telco%22%7D)

### 例

------------------------------------------------------------------------

#### 例1 - すべてのパス

これは、最初にデータ内のパスを探索する際によく使われるクエリーです。最小限の結果セットを返すもので、必要な結果カラムはパスのACCUMULATE()出力のみです。entity\_idを追加することで、必要に応じて元のデータにリンクすることができます。

nPath関数は、イベント、イベントのタイムスタンプ、セッションID、ユーザーID などのその他の情報で構成される入力テーブルを受け取ります。パターン マッチングの動作を制御するために、USING句にさまざまな引数を指定します。

パターンは、より具体的に調整できます。たとえば、パス内のイベントの数を制御するには、3つ以上6つ以下のイベントを持つパスについて A\* を A{3,6} に置き換えます。

``` sourceCode
SELECT * FROM npath
( 
   ON telco_events
   PARTITION BY entity_id,session_id
   ORDER BY datestamp
   USING 
     Mode (NonOverlapping)
     Pattern ('A*') 
     Symbols 
     (
         true as A 
     )
     Result 
     (
         FIRST ( entity_id of ANY (A) ) AS customer_id,
         ACCUMULATE (event of any(A) ) AS path
     )
)
SAMPLE 1000
;
```

結果句にさらに多くの列を定義して、結果を充実させることができます。以下は役立つ一般的な例です。

#### 例2 - イベントへのパス

複数のシンボル（以下のOとA）からなるパターンを使用することで、より複雑なマッチを作成できます。この場合、BILL DISPUTEに至るイベントで、送信前に最低2つ、最大6つのイベントが含まれます。なお、クエリーに標準SQLを追加することができます。この場合、最後にORDER BY句を追加します。

``` sourceCode
SELECT *
FROM npath
(
   ON (select top 100000 * from telco_events)  -- using select to control input records, use full table syntax when pattern finalized
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         event <> 'BILL DISPUTE'  as O,
         event = 'BILL DISPUTE'  as A
     )
     Pattern ('O{2,6}.A')

     Result
    (
         FIRST ( entity_id of ANY (A,O) )                  AS customer_id,
         FIRST ( session_id of ANY(A,O))                   AS session_id,
         COUNT ( * of any (A,O) )                          AS cnt,
         FIRST ( datestamp of ANY (A,O) )                  AS first_ts,
         LAST  ( datestamp of ANY (A,O) )                  AS last_ts,
         FIRST ( event of ANY (A,O) )                      AS first_event,
         LAST  ( event of ANY (A,O) )                      AS last_event,
         ACCUMULATE (event of any(A,O) )                   AS path
     )

     Mode (NONOVERLAPPING)
)
order by customer_id
SAMPLE 1000
;
```

#### 例3:パス方向を逆にする

パターンをA.O{1,3}に変更するだけで、アプリケーション送信後の経路を見つけることができます。これにより、送信後の顧客の行動を理解するために、最低1つから最大3つのイベントを含む経路を特定できます。

``` sourceCode
SELECT *
FROM npath
(
   ON (select top 100000 * from telco_events)  -- using select to control input records, use full table syntax when pattern finalized
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         event <> 'BILL DISPUTE'  as O,
         event = 'BILL DISPUTE'  as A
     )
     Pattern ('A.O{1,3}')

     Result
    (
         FIRST ( entity_id of ANY (A,O) )                  AS customer_id,
         FIRST ( session_id of ANY(A,O))                   AS session_id,
         COUNT ( * of any (A,O) )                          AS cnt,
         FIRST ( datestamp of ANY (A,O) )                  AS first_ts,
         LAST  ( datestamp of ANY (A,O) )                  AS last_ts,
         FIRST ( event of ANY (A,O) )                      AS first_event,
         LAST  ( event of ANY (A,O) )                      AS last_event,
         ACCUMULATE (event of any(A,O) )                   AS path
     )
     Mode (NONOVERLAPPING)
)
order by customer_id
SAMPLE 1000
;
```

#### 例4: トップパス

nPathクエリーをSQLのCOUNT/GROUP BY句でラップし、値を降順に並べることで、トップパスを迅速に見つけることができます。

また、以下のnPath PATTERN構文に注目してください。ここでは、最低3回の一致がある経路をフィルタリングしており、最大一致数は設定していません。構文は **{min, max}** です。

``` sourceCode
SELECT path, count(*) as cnt
FROM npath
(
   ON telco_events
   PARTITION BY entity_id,session_id
   ORDER BY datestamp  
   USING
     Symbols
     (
         true  as A
     )
     Pattern ('A{3,}')

     Result
     (
         FIRST ( entity_id of ANY (A) )                  AS customer_id,
         FIRST ( session_id of ANY(A))                   AS session_id,
         COUNT ( * of any (A) )                          AS cnt,
         FIRST ( event of ANY (A) )                      AS first_event,
         LAST  ( event of ANY (A) )                      AS last_event,
         ACCUMULATE (event of any(A) )                   AS path
     )

     Mode (NONOVERLAPPING)
)
group by 1
order by count(*) desc
SAMPLE 50
;
```

#### 例5: セッション化

多くの場合、データはユーザーイベントを簡単に定義できるセッションに分割しません。デジタルデータにはこの情報が含まれているかもしれませんが、複数のチャネルやデータソースを組み合わせると、ユーザーまたはエンティティのセッションを構成する境界を作成する必要があります。sessionize関数は、セッション内の各イベントを一意のセッション識別子にマッピングします。セッションは、1人のユーザーによるイベントのシーケンスで、秒単位の最大期間で区切られます。

この関数は、セッション化とWebクローラーボット(bot)の活動の検出の両方に役立ちます。ボットベースのイベントデータは、必要に応じて「click lag」値によって関数から自動的にフィルタリングされることがあります。

Sessionizeは、パターン検出を改善するためにnPathと併用することもできます。

``` sourceCode
select *
from Sessionize
(
    on (select * from telco_events where event = 'BILL DISPUTE' and entity_id = '353329')
    partition by entity_id
    order by datestamp
    using
    TimeColumn('datestamp')
    TimeOut(1200) -- 1200 seconds (20 minutes)
)
order by datestamp
SAMPLE 100
;
```

データセット
------------

------------------------------------------------------------------------

**telco\_events** - 通信事業者の顧客イベント例:

-   `entity_id`: 顧客の一意の識別子
-   `datestamp`: イベントの日時
-   `session_id`: セッション識別子
-   `event`: イベントまたは顧客とのインタラクション
