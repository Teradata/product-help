

## Historical Data Offload

Increasingly stringent regulations require companies to keep data online and accessible for regulatory compliance for many years. Although the data you access most frequently is the latest data, older data is still useful and relevant. Historical data compiled over the years gives a rich perspective of your business, such as long-term trends and cyclical patterns.

Teradata Vantage provides unmatched concurrency and performance for the world's largest and most demanding enterprises to analyze data. Analysis and concurrency needs for older information lessens substantially as the data ages. Because there is much more history data that accumulates than current  or "hot" data over time, it makes sense to store history data somewhere that has different performance and price characteristics, for example an object store such as Amazon S3 or Azure Blob storage.

Typically, keeping historical and current data in separate systems makes it a challenge to gain valuable insights. Teradata Vantage solves that challenge. You can seamlessly join together all historical and current information across the data warehouse and object storage, without having to change the basic data structures and queries. This makes it possible to cost-effectively answer questions that could not be previously addressed, allowing decision makers to better plan for the future.

### Before You Begin

1. Open Editor and log in using your DBC credentials.

   [LAUNCH EDITOR]

2. Load the built-in data set assets.

   [LOAD ASSETS]

## Walkthrough

* This use case takes approximately 10 minutes.
* Each step involves multiple actions that prepare you for the next step.
* Copy, paste, and run the code in Editor to follow along.

#### Step 1: Query the data.

Grab some sample rows from the current sales data to see customer, store, basket, and discount information:

```sql
SELECT TOP 10 * 
FROM retail_sample_data.so_sales_fact
```


```sql
SELECT sales_date, sum(sales_quantity) as total 
FROM retail_sample_data.so_sales_fact
GROUP BY sales_date
ORDER BY sales_date ASC
```


![png](output_7_0.png)



```sql
SELECT MIN(sales_date) AS min_date, MAX(sales_date) AS max_date FROM retail_sample_data.so_sales_fact
```

Find out how many records you have in the data arehouse:

```sql
SELECT COUNT(*)
FROM retail_sample_data.so_sales_fact
```
You have only have one year of sales data in your data warehouse because that was the data queried the most.

#### Step 2: Explore the offloaded historical data.

Although that year of data was queried the most, many companies need to keep up to 10 years of historical data for compliance. Vantage exports the older data on a monthly basis and loads into Amazon S3 for long-term storage. With Teradata Vantage, you can seamlessly access the offloaded data and join it with the rest of the data to get insights over long-term trends and handle audit requests with ease. This includes using existing queries and reports that would otherwise need to be rewritten.

Use the READ_NOS function to get a list of files and sizes from the offloaded data:

```sql
SELECT location(char(255)), ObjectLength 
FROM (
 LOCATION='/s3/s3.amazonaws.com/trial-datasets/SalesOffload'
 AUTHORIZATION=retail_sample_data.DEMO_AUTH_NOS
 RETURNTYPE='NOSREAD_KEYS'
) as d 
ORDER BY 1
```
Find out the total number of files and directories:

```sql
SELECT COUNT(location(char(255))) as NumFiles
FROM (
 LOCATION='/s3/s3.amazonaws.com/trial-datasets/SalesOffload'
 AUTHORIZATION=retail_sample_data.DEMO_AUTH_NOS
 RETURNTYPE='NOSREAD_KEYS'
) as d 
ORDER BY 1
```

To get a better understanding of the file format, take a look at one of the files:


```sql
SELECT * FROM (
      LOCATION='/s3/s3.amazonaws.com/trial-datasets/SalesOffload/2010/1/object_33_0_1.parquet'
      AUTHORIZATION=retail_sample_data.DEMO_AUTH_NOS
      RETURNTYPE='NOSREAD_PARQUET_SCHEMA'
      )
AS d
```

#### Step 3: Create a simple abstraction layer for easy access.

Create a foreign table with a view in Vantage that allows business analysts and other users to easily access the offloaded historical data:

```sql
CREATE FOREIGN TABLE retail_sample_data.sales_fact_offload
, EXTERNAL SECURITY retail_sample_data.DEMO_AUTH_NOS
USING
       (
LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload')
STOREDAS  ('PARQUET')
       )
NO PRIMARY INDEX
PARTITION BY COLUMN;
```

Take a look at some of the rows in the offloaded files: 

```sql
SELECT TOP 10 *
FROM retail_sample_data.sales_fact_offload;
```

Find out how much data you have out there:

```sql
SELECT COUNT(*)
FROM retail_sample_data.sales_fact_offload;
```

You're getting close. Apply a view to split the data into colummns so it looks like a native table:

```sql
REPLACE VIEW retail_sample_data.sales_fact_offload_v as (  
SELECT 
    sales_date,
    customer_id,
    store_id,
    basket_id,
    product_id,
    sales_quantity,
    discount_amount
FROM retail_sample_data.sales_fact_offload);
```

Now you can query the data like any other table in Teradata Vantage and have the data pulled directly from the object store at query runtime! Now you have a seamless analytic experience by supporting the correlation of object store-based data sets with structured data sets in Teradata relational tables using existing SQL skills and workflows. 


```sql
SELECT TOP 10 *
FROM retail_sample_data.sales_fact_offload_v;
```

That looks nice! Now our users can access all the historical data we have in the object store!

You can do everything in a view over a foreign table that you would do with a standard database view. This includes returning only a subset of the underlying table columns, as well as adding a WHERE clause in the view to limit what rows are made available using the view.

Often we want to be able to look at just a portion of this vast amount of data at a time, which is why we have stored it by year and month. Let's re-define the foreign table to allow us to pre-filter the data when reading it.

#### Step 3: Optimize the foreign table and view for efficient access

We have a lot of data in S3! Let's optimize the foreign table so that we minimize the data we have to read when querying the object store. Designing an object store bucket and path structure is an important first step when creating an object store. It requires knowledge of the business needs, the expected patterns in accessing the data, an understanding of the data, and a sensitivity to the tradeoffs. In our case we will often know the approximate date we are looking at, so will use this to our advantage.


```sql
DROP TABLE retail_sample_data.sales_fact_offload;
```

```sql
CREATE FOREIGN TABLE retail_sample_data.sales_fact_offload
, EXTERNAL SECURITY retail_sample_data.DEMO_AUTH_NOS
USING
       (
LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload')
PATHPATTERN ('$dir1/$year/$month')
STOREDAS  ('PARQUET')
       )
NO PRIMARY INDEX
PARTITION BY COLUMN;
```

We have re-defined our foreign table to include a <b>PATHPATTERN</b> clause. When looking at historical data by date, this allows us to read only the files we need!

Now let's re-create our user-friendly view that allows for this path filtering...


```sql
REPLACE VIEW retail_sample_data.sales_fact_offload_v as (  
SELECT 
    CAST($path.$year AS CHAR(4)) sales_year,
    CAST($path.$month AS CHAR(2)) sales_month,
    sales_date,
    customer_id,
    store_id,
    basket_id,
    product_id,
    sales_quantity,
    discount_amount
FROM retail_sample_data.sales_fact_offload);
```


```sql
SELECT TOP 10 *
FROM retail_sample_data.sales_fact_offload_v
WHERE sales_year = '2010'
AND sales_month = '9';
```

This is great for use cases where we know the date at least to the month. Suppose we need to see what a customer bought many years ago. Or maybe we want to report on historical store sales. The business analyst can easily query this with no IT intervention, no going to backups or other hard to reach data silos!

Let's take a look at what store 6 did for sales back in August 2012:


```sql
SELECT store_id, SUM(sales_quantity)
FROM retail_sample_data.sales_fact_offload_v
WHERE store_id = 6
AND sales_year = '2012'
AND sales_month = '8'
GROUP BY 1;
```


Let's join the historical data with the current data so we can see the full picture:


```sql
REPLACE VIEW retail_sample_data.sales_fact_all as (
SELECT sales_date,
    customer_id,
    store_id,
    basket_id,
    product_id,
    sales_quantity,
    discount_amount
    FROM retail_sample_data.so_sales_fact
    UNION ALL
SELECT 
    sales_date,
    customer_id,
    store_id,
    basket_id,
    product_id,
    sales_quantity,
    discount_amount
FROM retail_sample_data.sales_fact_offload_v);
```


Final thing we will do is re-run our sales over time report, code is unchanged from the one above, we are now able to analyse all the sales data and not just the most recent year.


```sql
SELECT sales_date, sum(sales_quantity) as total 
FROM retail_sample_data.sales_fact_all
GROUP BY sales_date
ORDER BY sales_date ASC;
```


![png](output_43_0.png)



Now we see that 2019 in the broader context was an off year, we will need to do further digging to see what happened. But thanks to Teradata Vantage we can cost-effectively analyse all our data by offloading the colder less queried data to object storage for safe keeping.

#### Step 5: Clean-up

Drop the objects we created in our own database schema.


```sql
DROP VIEW retail_sample_data.sales_fact_all;
```


```sql
DROP VIEW retail_sample_data.sales_fact_offload_v;
```


```sql
DROP TABLE retail_sample_data.sales_fact_offload;
```

## Dataset
***

The <b>sales_fact</b> dataset has approximately 43 million rows of sample sales data:

- `sales_date`: date the order was processed
- `customer_id`: customer identifier
- `store_id`: store identifier where the order was taken
- `basket_id`: grouping or order number
- `product_id`: identifier of the product
- `sales_quantity`: quantity of the product sold
- `discount_amount`: how much of a discount was given on this line item


