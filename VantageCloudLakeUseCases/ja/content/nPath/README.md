nPathを使用したパス分析 - パターンに基づく行動予測
--------------------------------------------------

### 始める前に

エディタを開いてこのユース ケースを進めます。[エディタを起動する](#data=%7B%22navigateTo%22:%22editor%22%7D)

### はじめに

nPathはSQL機能拡張で、順序データを高速に分析するために設計されています。

nPathの句によって、ANSI SQLでリレーションの複数レベルの結合を記述しなければならないような、複雑なパス クエリーや順序関係を表現できます。nPathでは、目的の順序を示し、順序データ間で照合されるパターンを指定します。行のシーケンスでパターンが一致するごとに、nPathは一致した行についてSQL 集約を計算します。

nPath分析では、結果につながるパスを追跡できます。例えば、顧客の行動の結果などです。

-   購買経路
-   カゴ落ち分析
-   離反経路
-   再入院などのペイシェント ジャーニー
-   不正行為につながるパス

### 通信業界の顧客移動の例

------------------------------------------------------------------------

テレコム業界では、顧客の解約(キャリア変更)への対処は大規模なコスト節約の取り組みです。nPath分析を使用すると、顧客行動に対する理解を深めリテンションを向上させる方法に焦点を当てることができます。

最初のステップとして、顧客が関与するインタラクションやトランザクションを統合したイベント テーブルを作成します。イベントをキャプチャすることで、来店、ウェブサイトへのアクセス、サポート ラインへの電話、サービスのアップグレード、サービスのキャンセルといったカスタマー ジャーニーを表示できます。

nPath分析の使用により、イベントをクリックしてビジネスに関する次のような疑問の答えを得られるようになりました。

-   顧客がウェブサイト上でどのようなパスをたどっているのか
-   顧客がサポート ラインに電話する前にどのようなパスをたどっているのか
-   顧客がサービスをキャンセルするまでにどのようなパスをたどっているのか

### 経験

このユース ケース全体の実施所要時間は約7分です。

### セットアップ

**アセットをロード** を選択してテーブルを作成し、このユース ケースに必要なデータを自分のアカウント(Teradataデータベース インスタンス)にロードします。[アセットをロード](#data=%7B%22id%22:%22Telco%22%7D)

### 例

------------------------------------------------------------------------

#### 例1 - 「すべてのパス」

これは、最初にデータ内のパスを探索する際によく使われるクエリーです。最小限の結果セットを返すもので、必要な結果カラムは「パス」のACCUMULATE()出力のみです。entity\_idを追加することで、必要に応じて元のデータにリンクすることができます。

また、パターンを調整してフォーカスを向上させることもできます。例えばパスのイベント数を制御するなどです。「3つ以上6つ以下のイベントを持つパス」について「A\*」を「A{3,6}」に置き換える

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

さらに多くのカラムを定義して、結果を充実させることができます。非常に役立つ一般例として、次のようなものがあります。

#### 例2 - 「イベントへのパス」

この例では、「送信前に2つ以上6つ以下のイベントを持つ、BILL DISPUTEに至るまでのイベント」パターンを使用しています。クエリーに標準SQLを追加できることに注目してください。この場合、最後に「order by」句が追加されています。

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

パターンをA.O{1,3}に変更するだけで、アプリケーション送信アクション後にたどったパスを特定できるようになりました。最大3つのイベントを含んでおり、送信後の顧客行動を理解できるようになっています。

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

#### 例4:「上位のパス」

nPathクエリーを標準SQL **count/group by** 構文でラップしDESCで並べ替えることで、上位のパスを素早く特定することができます。

また、nPathのPATTERN構文にも注目してください。ここでは、3つ以上、上限なしのイベントを持つパスでフィルタリングしています。構文は **{min, max}** です。

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

#### 例5:「Sessionize」

Sessionize関数は、セッション内の各クリックを一意なセッション識別子にマッピングします。セッションとは、1人のユーザーが最大n秒間隔でクリックする一連のシーケンスと定義されます。

この関数は、セッション化とウェブ クローラー(ボット)の活動検出の両方に役立ちます。通常、ウェブサイトにおけるユーザーの閲覧行動を理解するのに使用されます。SessionizeをnPathと併用することで、パターン検出を向上させることができます。

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
