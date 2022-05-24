## Deep History - Offloading cold historical data to an object store


### Introduction

Increasingly stringent regulations require companies to keep data online and accessible for regulatory compliance over many years. Although the most frequently accessed data is the latest or most current data, that doesn’t mean that the older information is not useful or relevant. Historical data that’s been compiled over the years gives a rich perspective of the business, such as long-term trends and cyclical patterns.

Teradata Vantage provides unmatched concurrency and performance for the world's largest and most demanding enterprises to analyze their data. Analysis and concurrency needs for older information is generally substantially less as data ages. Over time there is much more history data that accumulates than current 'hot' data, it makes sense to store it somewhere that has different performance and price characteristics: for example an object store such as Amazon S3 or Azure Blob storage.

Keeping historical and current data in separate systems can make it a challenge to gain unique insights that are possible only by analyzing the information together. But not any longer. Now, Teradata Vantage can be used to seamlessly join together all the historical and current information across the data warehouse AND object storage, without having to change the basic data structures and queries. This makes it possible to cost-effectively answer questions that could not be previously addressed so decision makers can better plan for the future.

### Experience

The Experience section takes about 10 minutes to run.

### Setup

Select **Load Assets** to create the tables and load the data required into your account (Teradata database instance) for this use case.
[Load Assets](#data={"id":"SalesOffload"})

### Walkthrough

#### Step 1: Querying the Data

Here is our current sales data. Lets grab some sample rows, we can see in this example we have customer, store, basket and discount information.


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

How many records do we have in the data warehouse (2019 data)?


```sql
SELECT COUNT(*)
FROM retail_sample_data.so_sales_fact
```


#### Step 2: Explore the offloaded historical data

As you have seen we only have 1 year of sales data in our data warehouse as this is by far the most queried, but for compliance many companies need to keep up to 10 years of historical data. The older data has been exported from Vantage on a monthly basis and loaded into Amazon S3 for long-term storage. With Teradata Vantage we can seamlessly access this offloaded data and join with the rest of the data to get insights over long-term trends and handle audit requests with ease. This includes using existing queries and reports that would otherwise need to be re-written!

We know the bucket where the offloaded sales data is located, so let's take a look at some of the data that is there - using the READ_NOS function we can get the list of files and their sizes.


```sql
SELECT location(char(255)), ObjectLength 
FROM read_nos (
ON (select cast(NULL AS DATASET INLINE LENGTH 64000 STORAGE FORMAT CSV))
USING 
 LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload')
 RETURNTYPE ('NOSREAD_KEYS')
) as d 
ORDER BY 1
```


How many files and directories are there total?


```sql
SELECT COUNT(location(char(255))) as NumFiles
FROM read_nos (
ON (select cast(NULL AS DATASET INLINE LENGTH 64000 STORAGE FORMAT CSV))
USING 
 LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload')
 RETURNTYPE ('NOSREAD_KEYS')
) as d 
ORDER BY 1
```


Let's take a look at one of the files to get a better understanding of the file format:


```sql
SELECT * FROM READ_NOS (
      USING
      LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload/2010/1/object_33_0_1.parquet')
      RETURNTYPE ('NOSREAD_PARQUET_SCHEMA')
      FULLSCAN ('TRUE')
      )
AS d
```


#### Step 3: Create a simple abstraction layer for easy access

Create a foreign table and a view in Vantage to allow business analysts and other users to easily access the offloaded historical data:

Note, you will need to list all the columns in the foreign table definition


```sql
CREATE FOREIGN TABLE sales_fact_offload
       (
Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
TheYear INTEGER,
TheMonth INTEGER,
sales_date DATE FORMAT 'YY/MM/DD',
customer_id INTEGER,
store_id INTEGER,
basket_id INTEGER,
product_id INTEGER,
sales_quantity INTEGER,
discount_amount FLOAT FORMAT '-ZZZ9.99'
)
USING
       (
LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload')
STOREDAS  ('PARQUET')
       )
NO PRIMARY INDEX
PARTITION BY COLUMN
```

Lets take a look at some of the rows that are in the offloaded files. 


```sql
SELECT TOP 10 *
FROM sales_fact_offload
```

How much data do we have out there?


```sql
SELECT COUNT(*)
FROM sales_fact_offload
```


Ok, we are close! We want the data to look like a native table. So let's put a view on top to split it out into colummns.


```sql
REPLACE VIEW sales_fact_offload_v as (  
SELECT 
    sales_date,
    customer_id,
    store_id,
    basket_id,
    product_id,
    sales_quantity,
    discount_amount
FROM sales_fact_offload)
```


Now we can query the data like any other table in Teradata Vantage, but the data is pulled at query runtime directly from the object store! We now have a seamless analytic experience by supporting the correlation of object store-based data sets with structured data sets in Teradata relational tables using existing SQL skills and workflows. 


```sql
SELECT TOP 10 *
FROM sales_fact_offload_v
```

That looks nice! Now our users can access all the historical data we have in the object store!

You can do everything in a view over a foreign table that you would do with a standard database view. This includes returning only a subset of the underlying table columns, as well as adding a WHERE clause in the view to limit what rows are made available using the view.

Often we want to be able to look at just a portion of this vast amount of data at a time, which is why we have stored it by year and month. Let's re-define the foreign table to allow us to pre-filter the data when reading it.

#### Step 3: Optimize the foreign table and view for efficient access

We have a lot of data in S3! Let's optimize the foreign table so that we minimize the data we have to read when querying the object store. Designing an object store bucket and path structure is an important first step when creating an object store. It requires knowledge of the business needs, the expected patterns in accessing the data, an understanding of the data, and a sensitivity to the tradeoffs. In our case we will often know the approximate date we are looking at, so will use this to our advantage.


```sql
DROP TABLE sales_fact_offload
```

```sql
CREATE FOREIGN TABLE sales_fact_offload
       (
Location VARCHAR(2048) CHARACTER SET UNICODE CASESPECIFIC,
TheYear INTEGER,
TheMonth INTEGER,
sales_date DATE FORMAT 'YY/MM/DD',
customer_id INTEGER,
store_id INTEGER,
basket_id INTEGER,
product_id INTEGER,
sales_quantity INTEGER,
discount_amount FLOAT FORMAT '-ZZZ9.99'
)
USING
       (
LOCATION  ('/s3/s3.amazonaws.com/trial-datasets/SalesOffload')
PATHPATTERN ('$dir1/$year/$month')
STOREDAS  ('PARQUET')
       )
NO PRIMARY INDEX
PARTITION BY COLUMN
```

We have re-defined our foreign table to include a <b>PATHPATTERN</b> clause. When looking at historical data by date, this allows us to read only the files we need!

Now let's re-create our user-friendly view that allows for this path filtering...


```sql
REPLACE VIEW sales_fact_offload_v as (  
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
FROM sales_fact_offload)
```


```sql
SELECT TOP 10 *
FROM sales_fact_offload_v
WHERE sales_year = '2010'
AND sales_month = '9'
```

This is great for use cases where we know the date at least to the month. Suppose we need to see what a customer bought many years ago. Or maybe we want to report on historical store sales. The business analyst can easily query this with no IT intervention, no going to backups or other hard to reach data silos!

Let's take a look at what store 6 did for sales back in August 2012:


```sql
SELECT store_id, SUM(sales_quantity)
FROM sales_fact_offload_v
WHERE store_id = 6
AND sales_year = '2012'
AND sales_month = '8'
GROUP BY 1
```


Let's join the historical data with the current data so we can see the full picture:


```sql
REPLACE VIEW sales_fact_all as (
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
FROM sales_fact_offload_v)
```


Final thing we will do is re-run our sales over time report, code is unchanged from the one above, we are now able to analyse all the sales data and not just the most recent year.


```sql
SELECT sales_date, sum(sales_quantity) as total 
FROM sales_fact_all
GROUP BY sales_date
ORDER BY sales_date ASC
```


![png](output_43_0.png)



Now we see that 2019 in the broader context was an off year, we will need to do further digging to see what happened. But thanks to Teradata Vantage we can cost-effectively analyse all our data by offloading the colder less queried data to object storage for safe keeping.

#### Step 5: Clean-up

Drop the objects we created in our own database schema.


```sql
DROP VIEW sales_fact_all
```


```sql
DROP VIEW sales_fact_offload_v
```


```sql
DROP TABLE sales_fact_offload
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

