# Path - Predict Behaviors Based on Patterns with No Coding!

- [Introduction](#introduction)
- [Telco Churn Example](#telco-churn-example)
- [Experience](#experience)
  - [Running Path](#running-path)
  - [Adding Additional Parameters](#adding-additional-parameters)
  - [Exporting Results](#exporting-results)
    - [Example 1: Export a List of Customers on the Path to Churn](#example-1:-export-a-list-of-customers-on-the-path-to-churn)
    - [Example 2: Save the Model Query](#example-2:-save-the-model-query)
    - [Example 3: Operationalize the Results With Workflow](#example-3:-operationalize-the-results-with-workflow)


# Introduction

Path provides user interfaces that help business users and data scientists understand patterns in customer behavior and build advanced predictive models. The models use the Machine Learning Engine (MLE).  Path incorporates nPath and Sessionize analytic functions running within the MLE. Users select events and parameters to explore event data, identify patterns, and reveal customer journeys.

Similiar to the nPath Analysis use case, this example shows how to track paths that lead to an outcome. But instead of writing SQL, it's just point and click!

# Telco Churn Example

In the telecommunications industry, addressing account closure--or *churn*--is a massive cost-saving effort. nPath analysis can target ways to improve retention by understanding customer behavior.

First, create an event table to integrate interactions and transactions involving the customer. By capturing these events, you can view the customer’s journey, such as visiting a store, going to the website, calling the support line, upgrading service, or canceling service.

Using nPath analysis, you can now click on the events to answer business questions, such as:

- What paths are my customers taking on the website?
- What paths are my customers taking before calling the support line?
- What paths are my customers taking before canceling their service?

# Experience

The entire use case takes about 5 minutes to run.

## Running Path

1. Open the <a href="/path-analyzer">Path</a>.
2. Select the system connection and authenticate.
3. Select the following "Event database": [%_PREFIX_%]Telco.
4. Select the following "Event table": telco_events.
5. Select additional parameters or just click "RUN" and analyze the results.

## Adding Additional Parameters

You may decide to use additional parameters for additional analysis:

- Top paths to show: Defines the number of pattern-matching paths to display
- Event A: Initial event in the search pattern
- Event B: Ending event in the search pattern
- Minimum event count: Minimum number of events in the path pattern
- Maximum event count: Maximum number of events in the path pattern

## Exporting Results

### Example 1: Export a List of Customers on the Path to Churn

To "Create Segement," create a table in the destination datasource with the structure below. You can create this table using the <a href="/editor">Editor</a>.

```sql
CREATE SET TABLE path_save_segment
(
     entity_id VARCHAR(100),
     path VARCHAR(2000)
)
;
```

### Example 2: Save the Model Query

To "Save Query," create a table in the destination datasource with the structure below. You can create this table using the <a href="/editor">Editor</a>.

```sql
CREATE SET TABLE path_segment_queries
(
 id        VARCHAR(100),
 name      VARCHAR(1000),
 query     VARCHAR(32000)
)
;
```

### Example 3: Operationalize the Results With Workflow

Use Workflow to run the results of the path analysis on a schedule. You can either save the path analysis and used it directly in a path node, or export the SQL and placed it in a SQL node. 
To use the SQL in a workflow, "Show SQL" then copy the SQL from your browser window. You can then paste these results into any <a href="/workflow/">workflow</a> SQL node. The "Show SQL "functionality is also useful in understanding how the SQL was constructed.
