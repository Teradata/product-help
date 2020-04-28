# Path - Predict Behaviors Based on Patterns with No Coding!

- [Introduction](#introduction)
- [Experience](#experience)
  - [Quick Start](#quick-start)
  - [Examples](#examples)
    - [Example 1: Save Segment](#)
    - [Example 2: Save Segment Queries](#)
- [Explore](#explore)

# Introduction

Path provides user interfaces that help business users and data scientists understand patterns in customer behavior and to build advanced predictive models. The models use the Machine Learning (ML) Engine. Path incorporates nPath and Sessionize analytic functions running within the Machine Learning Engine. Users select events and parameters to explore event data, identify patterns, and reveal customer journeys.
Similiar to the nPath Analysis use case, this example shows how to track paths that lead to an outcome. But instead of writing SQL, it's just point and click!

# Telco Churn Example

In the telecommunications industry, addressing account closure, or churn, is a massive cost-saving effort. Using nPath analysis can target ways in which to improve retention by understanding customer behavior.

The initial step involves creating an event table to integrate interactions and transactions involving the customer. By capturing the events you can view the customer’s journey, which may have involved visiting a store, going to the website, calling the support line, upgrading service, and canceling service.

Using nPath analysis, you can now click on the events to answer business questions, such as:

- What paths are my customers taking on the website?
- What paths are my customers taking before calling the support line?
- What paths are my customers before canceling their service?

# Experience

The entire use case takes about 5 minutes to run.

### Running Path

1. Open the <a href="/path-analyzer">Path</a>.
2. Select the system connection and authenticate.
3. Select the following "Event database": [%_PREFIX_%]Telco.
4. Select the following "Event table": telco_events.
5. Select additional parameters or just click "RUN" and analyze the results.

### Adding Additional Parameters

You may decide to use additional parameters for additional analysis

- Top paths to show: Defines the number of pattern-matching paths to display
- Event A: Initial event in the search pattern
- Event B: Ending event in the search pattern
- Minimum event count: Minimum number of events in the path pattern
- Maximum event count: Maximum number of events in the path pattern

### Exporting Results

#### Example 1 - 'Export a list of customers who are on the path to churn.'

In order to "Create Segement", a table in the destination datasource needs to exist with the structure below. This table can be created by using the <a href="/editor">Editor</a>.

```sql
CREATE SET TABLE path_save_segment
(
     entity_id VARCHAR(100),
     path VARCHAR(2000)
)
;
```

#### Example 2 - 'Save the model query'

In order to "Save Query" a table in the destination datasource needs to exist with the structure below. This table can be created by using the <a href="/editor">Editor</a>.

```sql
CREATE SET TABLE path_segment_queries
(
 id        VARCHAR(100),
 name      VARCHAR(1000),
 query     VARCHAR(32000)
)
;
```

#### Example 3 - 'Operationalize the results with workflow'

Workflow can be used in order to run the results of the path analysis on a schedule. The path analysis can either be saved and then used directly in a path node, or the SQL can be exported and placed in a SQL node. To use the SQL in a workflow, simply "Show SQL" and copy the SQL from your browser window. These results can then be pasted into any <a href="/workflow/">workflow</a> SQL node. The "Show SQL "functionality can also be useful in understanding how the SQL was constructed.
