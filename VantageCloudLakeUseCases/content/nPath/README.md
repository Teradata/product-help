## Path Analysis using nPath - Predict Behaviors Based on Patterns


### Introduction

nPath is an SQL extension designed to perform fast analysis on ordered data.

The clauses in nPath let you express complicated pathing queries and ordering relationships which might otherwise require you to write multi-level joins of relations in ANSI SQL. With nPath, you indicate a desired ordering and then specify a pattern that will be matched across the ordered data. For every match of the pattern in the sequence of rows, nPath computes an SQL aggregate over the matching rows.

nPath analysis helps track paths that lead to an outcome, including that of customer behavior:

- Path-to-purchase
- Abandoned cart analysis
- Path-to-churn
- Patient journeys, such as hospital readmission
- Paths leading to fraudulent activity


### Telco Churn Example
***

In the telecommunications industry, addressing account closure, or churn, is a massive cost-saving effort. Using nPath analysis can target ways in which to improve retention by understanding customer behavior.

The initial step involves creating an event table to integrate interactions and transactions involving the customer. By capturing the events you can view the customer’s journey, which may have involved visiting a store, going to the website, calling the support line, upgrading service, and canceling service.

Using nPath analysis, you can now click on the events to answer business questions, such as:

- What paths are my customers taking on the website?
- What paths are my customers taking before calling the support line?
- What paths are my customers before canceling their service?

### Experience
The entire use case takes about 7 minutes to run. 

### Setup

Click [Load Assets](#data={"id":"Telco"}) to create the tables and load the data required into your account (Teradata database instance) for this use-case.

### Examples
***

#### Example #1 - 'All Paths'

This is a common query when first exploring paths in the data. It returns a minimal result set; the only required result column is the ACCUMULATE() output for the 'path'. Adding the entity_id helps to link back to the original data, if needed.

The Pattern can also be tuned for better focus, for example, to control the number of events in the path. Replace 'A*' with A{3,6} for 'paths with at least 3 events and at most 6'


```sql
SELECT * FROM npath
( 
   ON retail_sample_data.telco_events
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

We're using a Pattern 'Events leading to BILL DISPUTE, with minimum of 2 and maximum of 6 events prior to Submit. Notice that we can add standard SQL to the query, in this case an order by clause at the end.


```sql
SELECT *
FROM npath
(
   ON (select top 100000 * from retail_sample_data.telco_events)  -- using select to control input records, use full table syntax when pattern finalized
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

By simply changing the Pattern to A.O{1,3} we can now find paths taken after the Application Submit action, with up to three events to understand customer behavior after Submission.


```sql
SELECT *
FROM npath
(
   ON (select top 100000 * from retail_sample_data.telco_events)  -- using select to control input records, use full table syntax when pattern finalized
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

By wrapping the nPath query with standard SQL <b>count/group by</b> syntax and ordering by DESC, we can quickly find the Top paths.

Also, notice the nPath PATTERN syntax. Here we're filtering by paths that have at least 3 events, with unbounded maximum. The syntax is <b>{min, max}</b>.


```sql
SELECT path, count(*) as cnt
FROM npath
(
   ON retail_sample_data.telco_events
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
    on (select * from retail_sample_data.telco_events where event = 'BILL DISPUTE' and entity_id = '353329')
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


# Explore

Tired of writing SQL for data analysis? See how <a href="/path/">Path</a> enables business users to self-sufficiently leverage the path analysis capabilities of Vantage, using point and click, without writing any code to explore and analyze customer data.

Or try <a href="/path/">Path</a> yourself today!

## Dataset
***

<b>telco_events</b> - Sample Telco customer events:

- `entity_id`: unique identifier for the customer
- `datestamp`: time and date of the event
- `session_id`: session identifier
- `event`: event or customer interaction
