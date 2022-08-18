## Total Knee Replacement - Path Analysis

### Before you begin

You must have the Vantage Editor open to complete this use case.
[LAUNCH EDITOR](#data={"navigateTo":"editor"})

### Introduction

This workbook provides a base demo script showcasing the capabilities of Vantage Path. The target audience is the Business Analyst.
The demo script has been constructed such that the Exploring Path to Total Knee Replacement section can be used in isolation (such as for a brief informal introductory meeting) or in combination with the other sections for a more complete demonstration. 

### Experience

The Experience section takes about 7-10 minutes to run.

First step is to open <a href="/path-analyzer">Vantage Path</a>.

### Setup

Select **Load Assets** to create the tables and load the data required into your account (Teradata database instance) for this use case.
[Load Assets](#data={"id":"KneeReplacement"})


### Walkthrough
***

#### Step 1: Exploring Path to Total Knee Replacement

I am going to be demonstrating the Vantage Path analysis capabilities using healthcare data.  Specifically, we are going to be looking at the most frequent medical procedures paths to total knee replacement.

Using the panel on the right I will set the values as follows:
- Leave the Top Paths to Show as 25
- Select the data source: 
    - Event Database: retail_sample_data
    - Event Table: knee_replacement


I am choosing not to set a filter and rather Use All events.
For the Event Pattern:
- Event A – leave as 'Any Event'
- Event B – change from 'Any Event' to 'Total Knee Replacement'
    
And I will leave the Min # events, Max # events and Allow overlap as the default settings.

For this demo scenario I do not need to limit the date range (however this filter could be useful in other situations).

Finally, I need to select the session column (entity_id) to tell path analysis which events belong in the same path.  Some path analysis such as paths on a website will be collated by session_id, in this scenario the session_id is equal to the patient (entity_id).

Once all the information required by the query has been entered, I can select the Run button, at which point a query is dynamically generated and sent to the Vantage system and in short order a visualization will be returned to us here in the interface.

#### Step 2: Visualization

The initial visualization that is returned highlights the most common path to Total Knee Replacement.

Once the visualization has returned, I have several options available:
- I can manually explore via expanded the path at each node of interest (clicking an open orange circle such as Knee Arthroscopy).  The solid orange circles indicate the full path for this node is being displayed.
- Expand All – Show all the Paths
- Collapse All – Shows only the Ending Event (Total Knee Replacement)
- Select Dominant – Highlights the most popular path

- I can all check the Show Count Labels the shows the number of people that that have passed through each specific path segment (e.g., Range of Motion Testing to Physical Therapy NEC).

- I can also toggle between path diagram and a table listing of the path events and count.  The table listing is what would have been returned if you had run this analysis via a direct query rather than the interface.

As you can see from viewing the dominant path, Knee Joint Biopsy is the most common last step before Total Knee Replacement.   Let’s explore this further to see if we can identify other pathways that have not led to Total Knee Replacement.
- First let’s explore Paths from Knee Joint Biopsy by selecting Knee Joint Biopsy as Event A and Any Event for Event B (Select Run).
- As expected, the dominant path ends up with Total Knee Replacement, however there are other procedures as well.

- Within Vantage Path we can easily switch the direction of the Path and let’s do so to explore a Path to Knee Joint Biopsy.  
- However, before selecting Run, we will check the Ending Anchor Option – this option will ensure Knee Joint Biopsy is the last event in the Path, and therefore the patients have not gone on to Total Knee Replacement.
- In this visualization we can see the most common path to Knee Joint biopsy and we may be interested in conducting further analysis on the patients on this path.

When the Dominant (or any Path for that matter) is chosen, I have the ability to store the results in a table for further analysis by using the Create Segment functionality

If you are not continuing on to demo Step 3: Create Segment, just skip the next section and onto the conclusion.

#### Step 3: Create Segment

To demo the Create Segment capability, an output table must already be created in your personal database (as write access is required). 

```sql
CREATE TABLE knee_replacement_path_export(
    entity_id    varchar(100),
    path        varchar(2000)
)
```

If you have previously run the demo and not re-created the table – ensure the table is empty, otherwise Save Segment will show 0 rows being inserted.
    
Path analysis allows for visual exploration and often when an interesting path is identified, then the people on that path are of interest for further analysis.  Let’s now explore the Create Segment capability.

When I click on the Create Segment button, I can choose a Database (that I have write access to) and a Table  --  (Use the one you created in Setup)

I now have a few options:
- Show SQL – this is the SQL that is run by Vantage. I can copy this SQL and paste into a query tool such as Vantage Editor or Jupyter for further exploration.
- Save Segment -  the query is run and the output is saved to the table specified. Once the query is completed, the number of rows will be displayed

    - Save Query –  with this option the query is given a name and the SQL is saved to a table on Vantage.

    - Now that I have saved a segment – let’s take a look at the resulting table. I am going to switch to Vantage Editor
    - If I view the insights from the knee_replacement_path_export table I can see that it has 2,757 records as well as the columns and ddl statement.
    - Running a simple select query I can see the result - Entity_id and Path (the dominant path selected).

- The saved segment can be used as input for further analysis, such as clustering to see if there are any commonalities across the patients or potentially as input to a treatment plan for these patients may be candidates for less invasive procedures.


#### Clean-up

When you are finished with this example, remember to clean up the created table:


```sql
DROP TABLE knee_replacement_path_export
```

#### Conclusion

As you can see from this brief demonstration, Vantage Analyst provides an easy to user interface for conducting path analysis such as the one we just viewed. Path analysis can span multiple topics and crosses industries. 

Examples include:
- Customer paths to purchase
- Online paths to cart abandonment
- Customer paths to complaints
- Paths to part failure

## Dataset
***

The <b>retail_sample_data.knee_replacement</b> dataset has 289,839 rows, each representing a procedure that a patient has undertaken. The dataset is denormalized so some patient information is repeated in each row:

- `memberid`: unique patient identifier
- `proccode`: procedure identifier
- `diagcode`: original diagnosis for the patient
- `shortdesc`: short description of the procedure
- `amount`: cost of the procedure
- `tstamp`: date and time of the procedure
- `firstname`: patient's first name
- `lastname`: patient's last name
- `email`: patient's email address
- `state`: state abbreviation for the patient

