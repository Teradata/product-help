Path analysis using nPath: Identify behaviors based on patterns
---------------------------------------------------------------

### Before you begin

Open Editor to proceed with this use case. [LAUNCH EDITOR](#data=%7B%22navigateTo%22:%22editor%22%7D)

### Introduction

nPath is an SQL extension designed to perform fast, flexible analysis on ordered data at massive scale.

The clauses in nPath let you express complicated pathing queries and ordering relationships which might otherwise require you to write multilevel joins of relations in American National Standards Institute (ANSI) SQL. With nPath, you indicate a desired ordering and then specify a pattern that will be matched across the ordered data. For every match of the pattern in the sequence of rows, nPath computes an SQL aggregate over the matching rows.

nPath analysis helps track paths that lead to an outcome, including that of customer behavior:

-   Path-to-purchase
-   Abandoned cart analysis
-   Path to churn
-   Patient journeys, such as hospital readmission
-   Paths leading to fraudulent activity

### Telco churn example

------------------------------------------------------------------------

In the telecommunications industry, addressing account closure, or churn, is a massive cost-saving effort. Using nPath analysis can target ways in which to improve retention by understanding customer behavior.

The initial step involves creating an event table to integrate interactions and transactions involving the customer. By capturing the events, you can analyze the customer’s journey, which may have involved visiting a store, going to the website, calling the support line, upgrading service, and canceling service.

Using nPath analysis, you can analyze these events in a very simple way to help answer business questions such as:

-   What paths are my customers taking on the website?
-   What paths are my customers taking before calling the support line?
-   What paths are my customers taking before canceling their service?

### Experience

The entire use case takes about 7 minutes to run.

### Setup

Select **Load Assets** to create the tables and load the data required into your account (Teradata database instance) for this use case. [Load Assets](#data=%7B%22id%22:%22Telco%22%7D)

### Examples

------------------------------------------------------------------------

#### Example \#1 - All paths

This is a common query when first exploring paths in the data. It returns a minimal result set; the only required result column is the ACCUMULATE() output for the path. Adding the entity\_id helps to link back to the original data, if needed.

The nPath function will take an input table consisting of events, the time stamp of the event, and any other information, such as session ID, user ID, etc. We provide various arguments to the USING clause to control the pattern matching behavior.

The pattern can be tuned for more specificity. For example, to control the number of events in the path, replace A\* with A{3,6} for paths with at least three events and at most six:

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

More columns can be defined in the result clause to enrich the results. Here are some common examples that can help.

#### Example \#2 - Paths to event

By using a pattern that consists of multiple symbols (O and A below), we can create a more complex match—in this case, events leading to BILL DISPUTE, with a minimum of two and maximum of six events prior to submission. Note that we can add standard SQL to the query—in this case, an ORDER BY clause at the end.

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

#### Example \#3: Reverse the path direction

By simply changing the pattern to A.O{1,3}, we can find paths taken after the application submission action, with a minimum of one and up to three events to understand customer behavior after submission.

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

#### Example \#4: Top paths

By wrapping the nPath query with SQL COUNT/GROUP BY clauses and ordering by descending value, we can quickly find the top paths.

Also, notice the nPath PATTERN syntax below. Here, we’re filtering by paths that have at minimum three matches, with no maximum number of matches. The syntax is **{min, max}**.

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

#### Example \#5: Sessionize

In many cases, the data will not split user events into easily definable sessions. While digital data may have this information, when we combine multiple channels or data sources, we need to create some boundary on what constitutes a user or entity session. The sessionize function maps each event in a session to a unique session identifier. A session is a sequence of events by one user separated by a maximum duration in seconds.

The function is useful both for sessionization and for detecting web crawler (bot) activity. Bot-based event data can be automatically filtered out of the function by a “click lag” value if desired.

Sessionize can also be used with nPath for improved pattern detection.

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

Dataset
-------

------------------------------------------------------------------------

**telco\_events** - Sample Telco customer events:

-   `entity_id`: unique identifier for the customer
-   `datestamp`: time and date of the event
-   `session_id`: session identifier
-   `event`: event or customer interaction
