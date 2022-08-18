## Time Series Analysis - Analyzing Consumer Complaints Over Time

### Before You Begin

Open Editor to proceed with this use case.
[LAUNCH EDITOR](#data={"navigateTo":"editor"})

### Introduction

In this example we will be analyzing the number of complaints over time received by the Consumer Financial Protection Bureau (CFPB).

How can we use Vantage to extract insights and tell a story behind a dataset? In this use case, you will see how powerful and simple it is to extract answers from a public dataset available through <a href="http://data.gov">Data.gov</a>. We use SQL and a visualization tool to analyze the number of complaints over time to answer the following questions:

<i>What are the trends of complaints over time? How can we interpret the outliers in the dataset?</i>

By answering questions like the ones above, we gain a deeper understanding of the dataset, and we can explain in plain language how the number of complaints evolve over time. In the Explore section, we focus on analyzing the number of complaints over time and identifying trends and outliers in the time series to answer the questions above.

### Experience

The Experience section takes about 5 minutes to run.

### Setup

Select **Load Assets** to create the tables and load the data required into your account (Teradata database instance) for this use case.
[Load Assets](#data={"id":"FinancialProtection"})

### Walkthrough

#### Step 1: Querying the Data
Start by counting the number of rows in the table.


```sql
select count(*) from retail_sample_data.fp_consumer_complaints;
```

There are just under 1.3 million rows. Not a problem to analyze large datasets using Vantage, let's take a look at a sample of the data.


```sql
select TOP 100 * from retail_sample_data.fp_consumer_complaints;
```

#### Step 2: Visualizing the Data

From the query above, we notice that this dataset has a lot of information. To derive some insights, we need to start grouping the data.

The first column is <b>date_received</b>. This is the date the complaints were received, and it means that we can look at a time series plot of the data. Let's start by grouping the counts of <b>complaint_id</b> over time, using <b>date_received</b> as our time axis.


```sql
select date_received, count(complaint_id) as counts
from retail_sample_data.fp_consumer_complaints
where date_received BETWEEN DATE '2017-03-01'
AND DATE '2019-03-01'
group by date_received;
```


This is great; we now have the number of complaints (<b>counts</b>) by time (<b>date_received</b>), but how do we make sense of this data? Let's plot this time series on a graph.


![png](output_10_0.png)


By visualizing the data above, we can see that the number of complaints varies a lot over time, and there also seem to be more complaints as time progresses. There are also some unusual spikes in 2017. Let's understand more about our data. We start by looking at the general trend.

Let's group the data by month and replot the graph above.


```sql
select extract(year from date_received) || extract(month from date_received) as month_date, count(complaint_id) as counts
from retail_sample_data.fp_consumer_complaints
group by month_date
order by month_date;
```

![png](output_13_0.png)


Looking at complaints over month and year, we see there is clearly an upward trend. One hypothesis is that as time progresses, people get more conscious and spread the word. The media can also advertise the complaint channels over time. Through this chart we can see clearly the spikes that we saw above were in January 2017 and September 2017. Let's dive deeper into these dates and draw some insights on the next step.

#### Step 3: Extracting Insights from the Data

Let's narrow down the two spikes above and see exactly where they are happening. We can do this by ploting another time series plot, this time only in 2017.


```sql
select date_received, count(complaint_id) as counts
from retail_sample_data.fp_consumer_complaints
where year(date_received) = 2017
group by date_received
order by date_received;
```


![png](output_17_0.png)



As we look at the peaks, we find that they occurred from January 15th to 21st and during the first week of September. To find the actual dates of the peaks, we can limit the query to pick up at least 1,500 complaints a day.


```sql
select date_received,
    month(date_received) as month_date,
    count(complaint_id) as counts
from retail_sample_data.fp_consumer_complaints
where year(date_received) = 2017 and month_date in (1, 9)
group by date_received
having counts >= 1500
order by month_date, counts desc;
```

Let's look at some of the issues that were reported during these dates.


```sql
select date_received, company, count(company) as counts
from retail_sample_data.fp_consumer_complaints
where date_received in (
    date '2017-01-19',
    date '2017-01-20',
    date '2017-09-08',
    date '2017-09-09',
    date '2017-09-13'
)
group by date_received, company
having counts > 500
order by date_received, counts desc;
```

Interestingly, we can see that the great majority of the the complaints were directed at two companies: Navient Solutions and EQUIFAX. These seem to be highly correlated with the Navient Lawsuit and the Equifax breach events that happened around those dates, respectively. Let's recap what happened:

<p>
<blockquote><i>Navient Lawsuit: On January 2017, the U.S. Consumer Financial Protection Bureau (CFPB) and the Illinois and Washington attorneys general sued Navient Solutions. Navient is a major servicer of private and federal student loans. Accoriding to the CFPB at least since January 2010 "Navient has misallocated payments, steered struggling borrowers toward multiple forbearances instead of income-driven repayment plans, and provided unclear information about how to re-enroll in income-driven repayment plans and how to qualify for a co-signer release"

Equifax Breach: On September 7th 2017, Equifax announced a cybersecurity breach, one of the largest in history, had happened from mid-May through July 2017. Some of the personal information that was accessed included names, social security numbers, birth dates, addresses and driver's license numbers.</i></blockquote>
</p>

Let's now look at the top issues for Navient Solutions and Equifax during those periods to confirm our hypothesis.


```sql
-- analyze top issues reported agains Navient Soultions on 2017-01-19 and 2017-01-20
select company, product, issue, count(issue) as counts
from retail_sample_data.fp_consumer_complaints
where date_received in (
    date '2017-01-19',
    date '2017-01-20') and
    company like 'Navient Solutions%'
group by company, product, issue
order by counts desc;
```

We can see the top two issues represent the majority of complaint counts against Navient Solutions. Furthermore, by looking at the product and issue columns we can infer that they are indeed related to the lawsuit regarding student loans. Now let's do the same analysis for the Equifax issues.


```sql
-- analyze top issues reported agains Navient Soultions on 2017-01-19 and 2017-01-20
select
    company,
    product,
    issue,
    count(issue) as counts
from retail_sample_data.fp_consumer_complaints
where date_received in (
    date '2017-09-08',
    date '2017-09-09',
    date '2017-09-13') and
        company like 'EQUIFAX%'
group by company, product, issue
order by counts desc;
```

Here we can also confirm our hypothesis. The top issues talk about improper use of the credit report, fraud alerts, identity theft etc. This really does seem related to the Equifax breach that happened around the same time frame.

## Dataset
***

The Consumer Complaints Database has complaints data that was received by the Consumer Financial Protection Bureau (CFPB) on financial products and services, which include but are not limited to bank accounts, credit cards, credit reporting, debt collection, money transfers, mortgages, student loans and other types of consumer credit. The dataset is refreshed daily and contains information on the provider, the complaint, date, ZIP code and more. More information about the dataset can be found in the Consumer section of the <a href="data.gov">Data.gov</a> website.

The <b>retail_sample_data.fp_consumer_complaints</b> dataset has 1,273,782 rows, each representing a unique consumer complaint, and 18 columns, representing the following features:

- `date_received`: date that CFPB received the complaint
- `product`: type of product the consumer identified in the complaint
- `sub_product`: type of sub-product the consumer identified in the complaint
- `issue`: issue the consumer identified in the complaint
- `sub_issue`: sub-issue the consumer identified in the complaint
- `consumer_complaint_narrative`: consumer-submitted description of "what happened" from the complaint
- `company_public_response`: company's optional, public-facing response to a consumer's complaint
- `company`: complaint is about this company
- `state`: state of the mailing address provided by the consumer
- `zip_code`: mailing ZIP code provided by the consumer
- `tags`: data that supports easier searching and sorting of complaints submitted by or on behalf of consumers
- `consumer_consent_provided`: identifies whether the consumer option in to publish their complaint narrative
- `submitted_via`: how the complaint was submitted to the CFPB
- `date_sent_to_company`: date the CFBP sent the complaint to the company
- `company_response_to_consumer`: how the company responded
- `timely_response`: whether the company gave a timely response
- `consumer_disputed`: whether the company disputed the company's response
- `complaint_id`: unique identification number for a complaint

## Explore

Through this example, we saw the power and simplicity of running queries in Vantage and how it can be leveraged to extract insights from the data to tell the story behind a dataset. Hopefully you've noticed how easy it is to use Vantage to write your own SQL queries.

You can continue to explore Vantage to extract more insights and find answers to other questions by using the preloaded dataset. Here are some suggestions:

- What are the most common types of complaints? By grouping the <b>product</b> category, we can arrive at this answer. How does this change over time?
- How are customers submitting their complaints? The column <b>submitted_via</b> can also be grouped to answer for this question.
- What proportion of the customer complaints are disputed? By aggregating counts of <b>customer_disputed</b> we can answer this question.
- Is there seasonality in the data? What is the reason for the seasonality? If we subtract the trend from the series we can analyze the seasonality in the dataset. Are most of the complaints filed during the week or on the weekends?
