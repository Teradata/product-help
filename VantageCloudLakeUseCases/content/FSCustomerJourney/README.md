## Financial Services Customer Journey

### Before You Begin

Open Editor to proceed with this use case.
[LAUNCH EDITOR](#data={"navigateTo":"editor"})

### Introduction

In this use case we will show several different analytic techniques to analyze various aspects of a customer journey using Vantage. Specifically we will use the Attribution and nPath functions.

Here is an overview of the scenario we will be covering: 

We want to look at the important interactions customers have with a retail bank. We would like to show how we can use Vantage to discover new insights across various steps in a customer journey. 

Starting with <b>customer acquisition</b>, how do we:
- Find new customers
- Measure marketing attribution
- How can we increase ROI and maximize marketing effectiveness, minimize the time to conversion.

Next we will look at <b>customer adoption</b>:
- What leads customers to additional high end products such as wealth management accounts?

Customers interact with the bank in many ways both online and offline
There are many different data sources such as in-branch interactions with tellers, online banking, email, call center logs, and others. It is necessary to look at <b>all</b> of them to see the full picture. 

Vantage is very adept at aggregating datasources, it has built in connectivity to various cloud object stores as well as QueryGrid connectors directly to Hadoop, Oracle and more.
We will be using an dataset aggregated from all of these channels. Other demos cover the integration and aggregation steps, but this is out of scope in our case.

We will see later that the insights we find are coming from these various channels both online AND offline.

## Experience

The entire use case takes about 10 minutes to run. 

### Setup

Select **Load Assets** to create the tables and load the data required into your account (Teradata database instance) for this use case.
[Load Assets](#data={"id":"FSCustomerJourney"})

### Customer Acquisition

This is the first part of our journey. We will focus on the opening of a credit card account. We want to figure out where our customers are coming from and how can we maximize our marketing return on investment (ROI)?
We will use the powerful marketing Attribution function in Vantage to look at the multi-channel data.

This will allow us to quantify marketing effectiveness of both our promotions and channels (online and offline). Which promotions are most effective? Using this information we can then optimize marketing spend and placement.

We will create some tables that allow us to send large numbers of parameters programmatically to the Attribution analytic function.


```sql
--DATABASE <database_name>;

CREATE TABLE FSCJ_conversion_events
   (conversion_event   VARCHAR(55))
NO PRIMARY INDEX;
```

We want to find when people have booked accounts both online and offline and use that as our success criteria:


```sql
INSERT INTO FSCJ_conversion_events VALUES('ACCOUNT_BOOKED_ONLINE');
INSERT INTO FSCJ_conversion_events VALUES('ACCOUNT_BOOKED_OFFLINE');
```

Vantage allows us to specify what type of attribution models we would like to apply. In this case we will keep it simple and choose a basic 'UNIFORM' strategy.


```sql
CREATE TABLE FSCJ_attribution_model
   (id    INTEGER,
    model VARCHAR(100))
NO PRIMARY INDEX;
```

```sql
INSERT INTO FSCJ_attribution_model VALUES(0, 'SIMPLE');
INSERT INTO FSCJ_attribution_model VALUES(1, 'UNIFORM:NA');
```

Now we are ready to invoke the Attribution function on our dataset. The dataset has all kinds of cross channel customer interactions we can analyse.


```sql
CREATE TABLE FSCJ_marketing_attribution AS (
    SELECT * FROM Attribution (
                ON (
          SELECT
                customer_identifier, interaction_timestamp, interaction_type, customer_days_active, customer_type,
                marketing_placement, marketing_description, marketing_category,
                interaction_type || product_category AS interaction_product
            FROM fscj_ich_banking
            WHERE
                interaction_type IN ('ACCOUNT_BOOKED_OFFLINE','ACCOUNT_BOOKED_ONLINE','CLICK','REFERRAL','BROWSE')
                AND product_category <> '-1'
        ) 
        PARTITION BY customer_identifier
        ORDER BY interaction_timestamp
        ON FSCJ_conversion_events AS ConversionEventTable DIMENSION
        ON FSCJ_attribution_model AS FirstModel DIMENSION
		USING
        EventColumn ('interaction_type')
        TimestampColumn ('interaction_timestamp')
        WindowSize('rows:10')
    ) as attrib)
    WITH DATA
```

Marketing attribution aims to identify the events leading to the opening of a credit card account and assign value to them. The specific conversion events in the data are 'ACCOUNT_BOOKED_ONLINE', 'ACCOUNT_BOOKED_OFFLINE'. Thus calculating the most influential events and channels that are driving customer aquisition. The attribution function in Vantage supports a variety of standard attribution models. Using Vantage we can quickly see how changes to the attribution model/parameters will affect our analyses!

Now lets get some summary statistics from the results:


```sql
SELECT marketing_description, AVG(attribution) AS avg_attrib, SUM(attribution) AS sum_attrib, AVG(-time_to_conversion)/3600 AS time_to_conversion
FROM FSCJ_marketing_attribution 
WHERE marketing_description NOT IN ('\N', '-1')
GROUP BY marketing_description;
```


![png](output_16_0.png)


![png](output_17_0.png)


![png](output_18_0.png)



The first visualization is centered around the various promotions we have run. The larger the bar the more influence they had towards a customer opening an account. 

The second chart shows the total attribution score the promotion had. So the biggest drivers of signups will be the longest. 

The third chart shows time to conversion, so how many hours on average that promotion took place before the user went ahead and signed up. The shorter time - lower on the chart - the faster people took action. We can see that the Gold Card Promotion II did overall the best, followed by the Hotel card and MoneySupermarket.com promotions.  

### Channel analysis

We have different promotions and advertising networks, now let's take a look at the traction we are getting with the various promotions across different channels:


```sql
SELECT marketing_category, marketing_placement, SUM(attribution) AS total_attribution 
FROM FSCJ_marketing_attribution 
WHERE marketing_description NOT IN ('\N', '-1')
GROUP BY 1, 2;
```

![png](output_22_0.png)


The next visual is centered around the various channels where we ran our marketing. The length of the bar shows the overall total attribution to that channel. The colors correspond to the promotions that we looked at in the top view, so we can see which promotions were on which channels and the performance of each. In the data resultset you can see that there is email, inbranch (offline) as well as web. 

For the digital channels - overall we can see that the homepage ads did the best followed by email and Google searches. 

Using a BI tool we can take this analysis to another level:

![png](AttributionDashboard.png)

Now we can see the promotions and their success across the various channels. We can see an interesting insight that the MoneySupermarket promotion and the Gold Card Promotion II were our most effective promotions. It is interesting to compare Gold Card II to the first Gold Card Promotion. Looking down at our channels we can see that the first Gold Card promotion was only run over email and the Gold Card Promotion II was run on multiple channels and it was a lot more effective for the same exact product. 

Using this dashboard and the power of Vantage can easily compare the different promotions and we can also see that we did a special promotion on MoneySupermarket.com that was particularly effective. This was only run on that particular channel and had both a quick time to conversion as well as strong average attribution.

We can also look at some other ones.. We can see that we did a Rewards Card promotion that did well across channels but was particularly effective through inbranch referrals. The airline card promotion did the best on the homepage and Google vs. the other channels.

## Path To Adoption

We want to see how our customers are opening higher end accounts such as wealth management. Many retail banks have found wealth management to be a key profit center so they are looking to build their business in this area.

We can use powerful nPath analytic function in Vantage to do pattern/time series analysis that is very hard to do in SQL. We want to see the common paths that customers take when they go to open a wealth management account. We will also look at the affiliation between the other accounts that wealth management customers hold. 

In the code here you can see a few key points:
1. We are concatenating the interaction and the product category to make unique events
2. We are ignoring the starting / completing of the wealth management application because everyone does that by definition and in this case we want to reduce the noise. Further analysis could be done later on incomplete applications or other scenarios.
3. The __'PATTERN'__ we are searching for 4 events followed by opening (ACCOUNT_BOOKED) a Wealth Management account.
4. The __'SYMBOLS'__ we are using anything but opening a wealth management account is 'EVENT' and openting said account is 'ADOPTION'


```sql
SELECT * FROM nPath (
        ON (
	    SELECT customer_identifier, interaction_timestamp, interaction_type, product_category, interaction_type || '_' || product_category AS event, 
                marketing_category, marketing_description, marketing_placement, sales_channel, 
                conversion_sales, conversion_cost, conversion_margin
            FROM fscj_ich_banking
            WHERE
                product_category <> '-1'
                AND interaction_type || '_' || product_category <> 'STARTS_APPLICATION_WEALTH MANAGEMENT'
                AND interaction_type || '_' || product_category <> 'COMPLETE_APPLICATION_WEALTH MANAGEMENT'
        )
        PARTITION BY customer_identifier
        ORDER BY interaction_timestamp
        USING
        MODE (NONOVERLAPPING)
        -- Limit to a depth of 4
        PATTERN ('(EVENT){4}.ADOPTION')
        SYMBOLS (
            event NOT LIKE 'ACCOUNT_BOOKED%_WEALTH MANAGEMENT' AS EVENT,
            event LIKE 'ACCOUNT_BOOKED%' AND product_category = 'WEALTH MANAGEMENT' AS ADOPTION
        )
        RESULT (
            ACCUMULATE( event OF ANY(EVENT,ADOPTION) )  AS interaction_type_list,
            COUNT( event OF ANY(EVENT,ADOPTION) )       AS click_depth,

            FIRST( customer_identifier of ADOPTION )  AS customer_identifier,
            FIRST( product_category OF ADOPTION )     AS product_category
        )
    ) a;
```


A visualization of this gives us lots of insight into the most common paths that users are taking when opening Wealth Management accounts:

![png](AdoptionPaths.png)

We can filter it down to the most popular paths:

![png](AdoptionPathsFiltered.png)

Now that we have a better view of what is happening let’s look at the main drivers in each case. 
  
So let’s start by looking at the drivers of wealth management accounts online. We can see that the ‘Compare’ tool that the bank has on its website is a main step in opening an account. This allows you to compare its wealth management offerings to its competitors and this is proving to be very compelling. So customers are browsing the offerings then using the compare tool and ultimately booking. 

The other main drivers of online account signups are people signing up for an auto-savings plan. So people that are savings minded tend to open wealth management accounts. Also general browsing the offerings and opening a CD appear to be secondary paths as well. 

Moving to offline - which we can see has different drivers. It appears to be predominately people that are opening other types of accounts as well such as CDs and Brokerage - both online and offline. We can see that the main path to booking a wealth management account offline is from in-branch referrals. So people go into a branch and are opening another type of account and they are referred to opening a wealth management account as well!

### Cleanup


```sql
DROP TABLE FSCJ_conversion_events;
```

```sql
DROP TABLE FSCJ_attribution_model;
```

```sql
DROP TABLE FSCJ_marketing_attribution;
```


### Dataset

The data for this use case, FSCustomerJourney, is stored in the `retail_sample_data` database. 

#### Integrated Contact History

This is the main table we use in this use case. It is data from various source systems and channels already combined and put into one big table. This is all of the customer interactions, in a customer system this might be a view on top of various source tables.

`fscj_ich_banking`

- `customer_skey`: customer key
- `customer_identifier`: unique customer identifier
- `customer_cookie`: cookie placed on customers device
- `customer_online_id`: boolean - does the customer have an online account
- `customer_offline_id`: customer account number
- `customer_type`: is this a high value customer or just a vistor browsing the website?
- `customer_days_active`: how long has the customer been active
- `interaction_session_number`: session identifier
- `interaction_timestamp`: timestamp for this event
- `interaction_source`: channel this event is from (online / offline, in branch etc.)
- `interaction_type`: type of event
- `sales_channel`: channel a sales event was in
- `conversion_id`: sales conversion identifier
- `product_category`: what type of product the event concerned (checking, savings, cd etc..)
- `product_type`: unused
- `conversion_sales`: unused
- `conversion_cost`: unused
- `conversion_margin`: unused
- `conversion_units`: unused
- `marketing_code`: marketing identifier
- `marketing_category`: marketing channel (inbranch, website, email etc..)
- `marketing_description`: marketing campaign name
- `marketing_placement`: specific marketing outlet (Google, Bloomberg.com etc..)
- `mobile_flag`: boolean was on a mobile device
- `updt`: unused
