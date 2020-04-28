# Path Analysis - Predict Behaviors Based on Patterns

- [Introduction](#introduction)
- [Experience](#experience)
  - [Quick Start](#quick-start)
  - [Examples](#examples)
    - [Example 1: All Paths](#)
    - [Example 2: Paths to Event](#)
    - [Example 3: Reverse the path direction](#)
    - [Example 4: Top Paths](#)
    - [Example 5: Sessionize](#)
- [Explore](#explore)

# Introduction

nPath is an SQL extension designed to perform fast analysis on ordered data. The clauses in nPath let you express complicated pathing queries and ordering relationships which might otherwise require you to write multi-level joins of relations in ANSI SQL. With nPath, you indicate a desired ordering and then specify a pattern that will be matched across the ordered data. For every match of the pattern in the sequence of rows, nPath computes an SQL aggregate over the matching rows.

nPath analysis helps track paths that lead to an outcome, including that of customer behavior:

- Path-to-purchase
- Abandoned cart analysis
- Path-to-churn
- Patient journeys, such as hospital readmission
- Paths leading to fraudulent activity

# Telco Churn Example

In the telecommunications industry, addressing account closure, or churn, is a massive cost-saving effort. Using nPath analysis can target ways in which to improve retention by understanding customer behavior.

The initial step involves creating an event table to integrate interactions and transactions involving the customer. By capturing the events you can view the customer’s journey, which may have involved visiting a store, going to the website, calling the support line, upgrading service, and canceling service.

Using nPath analysis, you can now click on the events to answer business questions, such as:

- What paths are my customers taking on the website?
- What paths are my customers taking before calling the support line?
- What paths are my customers before canceling their service?

# Experience

The entire use case takes about 7 minutes to run.

### Running SQL Code on Vantage

1. Click to open the <a href="/editor">Editor</a>.
1. Copy the SQL in each section below into the Editor and click **Run**.
1. View query results in the result panel.

### Examples

#### Example #1 - 'All Paths'

This is a common query when first exploring paths in the data. It returns a minimal result set; the only required result column is the ACCUMULATE() output for the 'path'. Adding the entity_id helps to link back to the original data, if needed.

The Pattern can also be tuned for better focus, for example, to control the number of events in the path. Replace 'A\*' with A{3,6} for 'paths with at least 3 events and at most 6'.

```sql
SELECT * FROM nPath
(
   ON [%_PREFIX_%]Telco.telco_events
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

More columns can be defined to enrich the results. Here are some common examples that can be very helpful.

#### Example #2 - 'Paths to Event'

We're using a Pattern 'Events leading to BILL DISPUTE', with minimum of 2 and maximum of 6 events prior to Submit. Notice that we can add standard SQL to the query, in this case an `order by` clause at the end.

```sql
SELECT *
FROM nPath
(
   ON (select top 100000 * from [%_PREFIX_%]Telco.telco_events)  -- using select to control input records, use full table syntax when pattern finalized
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

#### Example #3: Reverse the path direction

By simply changing the Pattern to `A.O{1,3}` we can now find paths taken after the Application Submit action, with up to three events to understand customer behavior after Submission.

```sql
SELECT *
FROM nPath
(
   -- ON titan_events
   ON (select top 100000 * from [%_PREFIX_%]Telco.telco_events)  -- using select to control input records, use full table syntax when pattern finalized
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

#### Example #4: 'Top Paths'

By wrapping the nPath query with standard SQL `count/group by` syntax and ordering by DESC, we can quickly find the Top paths.

Also, notice the nPath PATTERN syntax. Here we're filtering by paths that have at least 3 events, with unbounded maximum. The syntax is `{min, max}`.

```sql
SELECT path, count(*) as cnt
FROM nPath
(
   ON [%_PREFIX_%]Telco.Telco_events
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

#### Example #5: 'Sessionize'

The Sessionize function maps each click in a session to a unique session identifier. A session is defined as a sequence of clicks by one user that are separated by at most n seconds.

The function is useful both for sessionization and for detecting web crawler (bot) activity. It is typically used to understand user browsing behavior on a web site. Sessionize can be used with nPath for improved pattern detection.

```sql
select *
from Sessionize
(
    on (select * from [%_PREFIX_%]Telco.telco_events where event = 'BILL DISPUTE' and entity_id = '353329')
    partition by entity_id
    order by datestamp
    using
    TimeColumn('datestamp')
    TimeOut(1200) -- 600 seconds (10 minutes)
)
order by datestamp
SAMPLE 100
;
```

# Explore

Tired of writing SQL for data analysis? See how <a href="https://www.teradata.in/Resources/Demos/Customer-Churn-Analysis-with-Vantage-Analytic-Apps">Path</a> enables business users to self-sufficiently leverage the path analysis capabilities of Vantage, using point and click, without writing any code to explore and analyze customer data.

Or try <a href="/path-analyzer">Path</a> yourself today!
