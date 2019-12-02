# Bust Out Fraud - First Party Financial Fraud Prediction

- [Introduction](#introduction)
- [Experience](#experience)
  - [Quick Start](#quick-start)
  - [Walkthrough](#walkthrough)
    - [Step 1: Generate Features](#step-1-generate-features)
    - [Step 2: Create Model](#step-2-create-model)
    - [Step 3: Prediction](#step-3-prediction)
    - [Step 4: Visualizing Results](#step-4-visualizing-results)
- [Datasets](#datasets)
- [Explore](#explore)

# Introduction

Teradata has been working with several of the world’s largest banks to improve financial crimes interdiction. Financial crimes include many forms of criminal behaviour; such as payment fraud, money laundering, and cybercrimes.

Historically, banks relied on “rules-based engines” to flag questionable activities. Rules-based engines leverage historical precedence and light analytics. The problem is that the rules-based engines can't keep up. With the rise in digital financial channels and increasingly sophisticated criminals, threats literally change overnight. The financial crime and compliance burden keeps getting worse.

Artificial Intelligence (AI), such as that provided in Teradata's Machine Learning Engine, has proven to catch crimes that rules engines can’t. AI quickly adapts to fast evolving criminal schemes, as relationships are determined automatically, and is less affected by messy or extraneous data.

Teradata has successfully implemented AI to detect financial crimes at several banks where we’ve improved fraud detection rates by >50%.

The financial crime of interest here is “first party fraud,” aka “bust-out fraud.” It occurs when a consumer applies for and uses credit, using their own or a false identity, to make transactions. The fraudster makes on-time payments to maintain a good account standing. By building a history of good behaviour with timely payments and low utilization, they eventually obtain additional lines of credit with higher limits. Eventually they use all the available credit and stop making payments.

Using the power of **Vantage**, we can generate feature tables from the raw data, perform model training and scoring all in one platform, at scale, to predict customers that may be on the verge of committing this type of first party financial fraud. The **Experience** section walks through the entire process, and the end visualisation is done using a BI dashboarding tool.

# Experience

### Quick Start

The **Experience** section takes about 10 minutes to run.

#### Running SQL Code on Vantage

1. Click to open the [SQL Editor](../../../../../../editor).
1. Copy the SQL in each section below into the Editor and click **Run**.
1. View query results in the result panel.

### Walkthrough

#### Step 1: Generate Features

First we need to generate features from the integrated data we have about our customers and accounts.

Begin by calculating a daily summary per account of the count of different types of transactions the customer has made.

```sql
CREATE MULTISET TABLE "${UserName}".transaction_daily_counts AS (
 SELECT
       DTL.acct_no,
       DTL.tran_post_dt,

       CASE
           WHEN DTL.TRAN_CAT_CD = 19 AND DTL.TRANS_CHNL NOT IN ('NSF') THEN 'PAYMENT'
       ELSE DTL.TRANS_CHNL
       END AS TRANS_TYPE,

       CASE
           WHEN DTL.TRAN_CAT_CD = 19 THEN DTL.TRANS_CHNL
       ELSE NULL
       END AS PAYMENT_CHNL,
           SUM(DTL.TRANS_AMT) AS Sum_Amt,
           COUNT(*) AS Trans_Cnt
       FROM [%_PREFIX_%]BUSTOUTFRAUD.TRANSACTION_DETAIL DTL
       GROUP BY ACCT_NO,
           TRAN_POST_DT,
           TRANS_TYPE,
           PAYMENT_CHNL
) WITH DATA;
```

Note the use of `"${UserName}"` in the SQL above. This syntax provides a way to include parameters in a SQL statement. When you copy and paste this into the SQL Editor you will be prompted to enter your username for the default database to create the table in.

Next, aggregate monthly features based upon the account statements and credit bureau data.

```sql
CREATE MULTISET TABLE "${UserName}".acct_feature AS (
  SELECT
      CBD.ACCT_NO,
      CBD.AS_OF_DT,
      CBD.ACCTS_CLSD_BY_GRANTOR_CT,
      CBD.ACCTS_OPEN_12M_CT,
      CBD.ACCTS_UTLZ_GE95_CT,
      CBD.CREDIT_SCORE,
      CBD.INQ_BANK_6M_CT,
      CBD.ACCTS_AVG_AGE_MTH_CT,
      CBD.MSA_CD,
      MAS.ACQ_CHNL,
      MAS.ACQ_ECOM_FLAG,
      MAS.MTH_ON_BOOK,
      MAS.CREDIT_LIMIT,
      MAS.EOM_BAL_AMOUNT
      FROM [%_PREFIX_%]BUSTOUTFRAUD.CREDIT_BUREAU_DATA CBD
      JOIN [%_PREFIX_%]BUSTOUTFRAUD.ACCT_STATEMENT MAS
      ON CBD.ACCT_NO  = MAS.ACCT_NO
      AND CBD.AS_OF_DT = MAS.AS_OF_DT_DAY
) WITH DATA;
```

Now build an intermediate table for Daily Derived Transaction Features. Features include sums and counts of payments and purchases over different time periods that prove useful in fraud prediction.

```sql
CREATE MULTISET TABLE "${UserName}".trans_feature_day_derived AS (
    SELECT
        ACCT_NO,
        AS_OF_DT,
        ZEROIFNULL(PMT_AMT) AS PMT_AMT,
        PMT_CNT,
        SUM(PMT_AMT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 7 PRECEDING) (DECIMAL(12,2)) AS PMT_SUM_7DAY,
            SUM(PMT_AMT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 30 PRECEDING) (DECIMAL(12,2)) AS PMT_SUM_30DAY,
            SUM(PMT_AMT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 60 PRECEDING) (DECIMAL(12,2)) AS PMT_SUM_60DAY,
            AVG(PMT_AMT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 150 PRECEDING) (DECIMAL(12,2)) AS DAVG_PMT_05,
            SUM(PMT_CNT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 7 PRECEDING) (INTEGER) AS PMT_CNT_7DAY,
            SUM(PMT_CNT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 30 PRECEDING) (INTEGER) AS PMT_CNT_30DAY,
            SUM(PMT_CNT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 60 PRECEDING) (INTEGER) AS PMT_CNT_60DAY,
            (AS_OF_DT - MAX(PMT_DAY) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 720 PRECEDING)) (INTEGER) AS DAYS_SINCE_LSTPMT,
            (MAX(ABS(EPMT)) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 7 PRECEDING)*-1) (DECIMAL(12,2)) AS MAXAMT_EPMT_V7DAY,
            PAYCHNL_CNT,
            EPMT_FLAG,
            CPMT_FLAG,
            CKPMT_FLAG,
            PPMT_FLAG,
            OTHERPMT_FLAG,
            SUM(CASH_AMT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 7 PRECEDING) (DECIMAL(12,2)) AS CASH_SUM_7DAY,
            (AS_OF_DT - MAX(CASH_DAY) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 720 PRECEDING)) (INTEGER) AS DAYS_SINCE_LSTCASH,
            SUM(PURCH_CNT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 365 PRECEDING) (INTEGER) AS LAST_12_MTH_RTL_TRAN_CT2,
            SUM(PURCH_CNT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 7 PRECEDING) (INTEGER) AS PURCH_CNT_7DAY,
            SUM(PURCH_CNT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 60 PRECEDING) (INTEGER) AS PURCH_CNT_60DAY,
            SUM(PURCH_AMT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 7 PRECEDING) (DECIMAL(12,2)) AS PURCH_SUM_7DAY,
            SUM(PURCH_AMT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 30 PRECEDING) (DECIMAL(12,2)) AS PURCH_SUM_30DAY,
            SUM(PURCH_AMT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 60 PRECEDING) (DECIMAL(12,2)) AS PURCH_SUM_60DAY,
            SUM(NSF_CNT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 30 PRECEDING) (INTEGER) AS NSF_CNT_30DAY,
            SUM(NSF_CNT) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT ROWS 90 PRECEDING) (INTEGER) AS NSF_CNT_90DAY,
            (CASH_SUM_7DAY + PURCH_SUM_7DAY) AS PURCASH_SUM_7DAY
        FROM
        (
        SELECT
            ad.acct_no,
            COALESCE(Cnt.tran_post_dt,ad.date_range) AS as_of_dt,
            COALESCE(Cnt.trans_type,'NO ACTIVITY') AS trans_type,

            CASE
                WHEN trans_type = 'PURCHASE' THEN SUM_AMT ELSE 0
            END AS PURCH_AMT,

            CASE
                WHEN trans_type = 'PURCHASE' THEN TRANS_CNT ELSE 0
            END AS PURCH_CNT,

            CASE
                WHEN trans_type = 'NSF'      THEN SUM_AMT ELSE 0
            END AS NSF_AMT,

            CASE
                WHEN trans_type = 'NSF'      THEN TRANS_CNT ELSE 0
            END AS NSF_CNT,

            CASE
                WHEN trans_type = 'CASH'     THEN SUM_AMT ELSE 0
            END AS CASH_AMT,

            CASE
                WHEN trans_type = 'CASH'     THEN TRANS_CNT ELSE 0
            END AS CASH_CNT,

            CASE
                WHEN trans_type = 'CASH'     THEN tran_post_dt ELSE NULL
            END AS CASH_DAY,
                SUM(
            CASE
                WHEN trans_type = 'PAYMENT' THEN SUM_AMT ELSE NULL
            END) AS PMT_AMT,
                SUM(
            CASE
                WHEN trans_type = 'PAYMENT' THEN TRANS_CNT ELSE 0
            END) AS PMT_CNT,
                MAX(
            CASE
                WHEN trans_type = 'PAYMENT' THEN tran_post_dt ELSE NULL
            END) AS PMT_DAY,
                (MAX(ABS(
            CASE
                WHEN trans_type = 'PAYMENT' AND PAYMENT_CHNL = 'EPAYMENT' THEN SUM_AMT ELSE 0
            END))*-1) AS EPMT,
                MAX(
            CASE
                WHEN trans_type = 'PAYMENT' AND PAYMENT_CHNL = 'EPAYMENT' THEN 'Y' ELSE 'N'
            END) AS EPMT_FLAG,
                MAX(
            CASE
                WHEN trans_type = 'PAYMENT' AND PAYMENT_CHNL = 'CPAYMENT' THEN 'Y' ELSE 'N'
            END) AS CPMT_FLAG,
                MAX(
            CASE
                WHEN trans_type = 'PAYMENT' AND PAYMENT_CHNL = 'CKPAYMENT' THEN 'Y' ELSE 'N'
            END) AS CKPMT_FLAG,
                MAX(
            CASE
                WHEN trans_type = 'PAYMENT' AND PAYMENT_CHNL = 'PPAYMENT' THEN 'Y' ELSE 'N'
            END) AS PPMT_FLAG,
                MAX(
            CASE
                WHEN trans_type = 'PAYMENT' AND PAYMENT_CHNL IN ('APAYMENT','VDRPAYMENT','TTPAYMENT','CRDPAYMENT','ADJPAYMENT','NONE') THEN 'Y' ELSE 'N'
            END) AS OTHERPMT_FLAG,
                SUM(
            CASE
                WHEN trans_type = 'PAYMENT' THEN 1 ELSE 0
            END) AS PAYCHNL_CNT
            FROM [%_PREFIX_%]BUSTOUTFRAUD.TRANSACTION_DAILY_COUNTS Cnt
            RIGHT JOIN [%_PREFIX_%]BUSTOUTFRAUD.ALL_DATES ad
            ON  ad.acct_no = Cnt.acct_no
            AND ad.date_range = Cnt.tran_post_dt
            GROUP BY 1,
                2,
                3,
                4,
                5,
                6,
                7,
                8,
                9,
                10
        ) IJ
        WHERE trans_type IS NOT NULL
    ) WITH DATA;
```

Now build an intermediate table for Monthly Derived Transaction Feature. This allows us to look at the balance, credit limit, and utilization.

```sql
CREATE MULTISET TABLE "${UserName}".trans_feature_month_derived AS (
    SELECT
        ACCT_NO,
        AS_OF_DT_DAY,
        CREDIT_LIMIT,
        EOM_BAL_AMOUNT,

        CASE
            WHEN CREDIT_LIMIT = 0 THEN NULL
        ELSE (((EOM_BAL_AMOUNT * 100) (DECIMAL(20,5))) / CREDIT_LIMIT)
        END (DECIMAL(12,5)) AS CREDIT_UTIL_CUR_MONTH,
            AVG(CREDIT_UTIL_CUR_MONTH) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT_DAY ROWS 5 PRECEDING) (DECIMAL(20,5)) AS CREDIT_UTIL_PRIOR_5_MTH,
            AVG(CREDIT_UTIL_CUR_MONTH) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT_DAY ROWS 6 PRECEDING) (DECIMAL(20,5)) AS AVGLINE_UTIL_L6M,

        CASE
            WHEN CREDIT_UTIL_PRIOR_5_MTH = 0 THEN NULL
        ELSE (((CREDIT_UTIL_CUR_MONTH) (DECIMAL(20,5))) / CREDIT_UTIL_PRIOR_5_MTH)
        END (DECIMAL(20,5)) AS CREDIT_UTIL_CUR_TO_PRIOR_RATIO,
            MAX(CREDIT_UTIL_CUR_MONTH) OVER (PARTITION BY ACCT_NO
        ORDER BY AS_OF_DT_DAY ROWS 5 PRECEDING) (DECIMAL(20,5)) AS MAX_UTILIZATION_05_MTH
        FROM [%_PREFIX_%]BUSTOUTFRAUD.ACCT_STATEMENT
    ) WITH DATA;
```

Now that we have done all that, let's do a final insert into the `TRANS_FEATURE` table that combines monthly and daily transactions features into a single table. It produces a single row per `as_of_dt` per `acct_no`. We can use this table to train the model and do predictions to prevent future fraud.

```sql
CREATE MULTISET TABLE "${UserName}".trans_feature AS (
  SELECT
      DY.ACCT_NO AS acct_no,
      DY.AS_OF_DT AS as_of_dt_day,
      DY.DAVG_PMT_05 AS avg_pmt_05_mth,
      DY.DAYS_SINCE_LSTCASH AS days_since_lstcash,
      MTH.MAX_UTILIZATION_05_MTH AS max_utilization_05_mth,
      DY.MAXAMT_EPMT_V7DAY AS maxamt_epmt_v7day,
      DY.NSF_CNT_90DAY AS times_nsf,
      MTH.CREDIT_UTIL_CUR_MONTH AS credit_util_cur_mth,
      MTH.CREDIT_UTIL_PRIOR_5_MTH AS credit_util_prior_5_mth,
      MTH.CREDIT_UTIL_CUR_TO_PRIOR_RATIO AS credit_util_cur_to_prior_ratio,
      DY.DAYS_SINCE_LSTPMT AS days_since_lst_pymnt,
      DY.PMT_CNT_7DAY AS num_pymnt_lst_7_days,
      DY.PMT_CNT_60DAY AS num_pymnt_lst_60_days,
      DY.PURCH_CNT_7DAY AS num_pur_lst_7_days,
      DY.PURCH_CNT_60DAY AS num_pur_lst_60_days,
      DY.PAYCHNL_CNT AS tot_pymnt_chnl,
      DY.PPMT_FLAG AS pay_by_phone,
      DY.EPMT_FLAG AS elec_pymnt,
      DY.CPMT_FLAG AS pay_in_bank,
      DY.CKPMT_FLAG AS pay_by_check,
      DY.OTHERPMT_FLAG AS pay_by_othr,
      DY.LAST_12_MTH_RTL_TRAN_CT2 AS last_12m_trans_ct
      FROM "${UserName}".TRANS_FEATURE_MONTH_DERIVED MTH
      JOIN
      (
      SELECT
          ACCT_NO,
          AS_OF_DT,
          SUM(PMT_AMT) AS TOT_PYMNT_AM,
          SUM(PMT_CNT) AS TOT_PYMNT,
          MIN(PMT_SUM_7DAY) AS PMT_SUM_7DAY,
          MIN(PMT_SUM_30DAY) AS PMT_SUM_30DAY,
          MIN(PMT_SUM_60DAY) AS PMT_SUM_60DAY,
          MAX(DAVG_PMT_05) AS DAVG_PMT_05,
          MAX(PMT_CNT_7DAY) AS PMT_CNT_7DAY,
          MAX(PMT_CNT_30DAY) AS PMT_CNT_30DAY,
          MAX(PMT_CNT_60DAY) AS PMT_CNT_60DAY,
          MIN(DAYS_SINCE_LSTPMT) AS DAYS_SINCE_LSTPMT,
          MIN(MAXAMT_EPMT_V7DAY) AS MAXAMT_EPMT_V7DAY,
          MAX(PAYCHNL_CNT) AS PAYCHNL_CNT,
          MAX(EPMT_FLAG) AS EPMT_FLAG,
          MAX(CPMT_FLAG) AS CPMT_FLAG,
          MAX(CKPMT_FLAG) AS CKPMT_FLAG,
          MAX(PPMT_FLAG) AS PPMT_FLAG,
          MAX(OTHERPMT_FLAG) AS OTHERPMT_FLAG,
          MAX(CASH_SUM_7DAY) AS CASH_SUM_7DAY,
          MAX(DAYS_SINCE_LSTCASH) AS DAYS_SINCE_LSTCASH,
          MAX(LAST_12_MTH_RTL_TRAN_CT2) AS LAST_12_MTH_RTL_TRAN_CT2,
          MAX(PURCH_CNT_7DAY) AS PURCH_CNT_7DAY,
          MAX(PURCH_CNT_60DAY) AS PURCH_CNT_60DAY,
          MAX(PURCH_SUM_7DAY)  AS PURCH_SUM_7DAY,
          MAX(PURCH_SUM_60DAY) AS PURCH_SUM_60DAY,
          MAX(NSF_CNT_30DAY) AS NSF_CNT_30DAY,
          MAX(NSF_CNT_90DAY) AS NSF_CNT_90DAY,
          MAX(PURCASH_SUM_7DAY) AS PURCASH_SUM_7DAY
          FROM "${UserName}".TRANS_FEATURE_DAY_DERIVED
          GROUP BY 1,
              2
      ) DY
      ON (DY.AS_OF_DT/100) = (MTH.AS_OF_DT_DAY/100)  /*Assuming that the MTH table has ONLY one day per month in there per acct_no. If all dates are in there, then remove the /100 condition */
      AND DY.ACCT_NO  = MTH.ACCT_NO
) WITH DATA;
```

#### Step 2: Create the Model

Generate a model based on accounts that we know have already busted out - these are the training set (in a view). The model is stored directly in Vantage for use in scoring currently active accounts.

```sql
SELECT *
    FROM XGBoost(
    ON [%_PREFIX_%]BustOutFraud.v_trans_feature_train AS InputTable
    OUT TABLE OutputTable("${UserName}".trans_feature_xgboost_model)
    USING
    ResponseColumn('bustout')
    PredictionType('classification')
    NumericInputs('avg_pmt_05_mth', 'max_utilization_05_mth', 'maxamt_epmt_v7day',
    'credit_util_cur_mth', 'credit_util_prior_5_mth', 'credit_util_cur_to_prior_ratio',
    'days_since_lst_pymnt', 'num_pymnt_lst_7_days', 'num_pymnt_lst_60_days',
    'num_pur_lst_7_days', 'num_pur_lst_60_days', 'tot_pymnt_chnl', 'times_nsf', 'last_12m_trans_ct')
    CategoricalInputs('pay_by_phone', 'elec_pymnt', 'pay_in_bank', 'pay_by_check', 'pay_by_othr')
    LossFunction('binomial')
    IterNum(10)
    MaxDepth(10)
    MinNodeSize(1)
    RegularizationLambda('1')
    ShrinkageFactor('0.1')
    ) AS dt;
```

#### Step 3: Prediction

Use the calculated feature set and the model we created to predict accounts that have possible fraudulent behaviour. Save the results in the `acct_predict` table for later analysis.

```sql
CREATE MULTISET TABLE "${UserName}".acct_predict AS (
   SELECT *
       FROM XGBoostPredict (
       ON "${UserName}".trans_feature AS "input" PARTITION BY ANY
       ON "${UserName}".trans_feature_xgboost_model AS modeltable DIMENSION
       ORDER BY tree_id,
           iter,
           class_num
       USING
       Accumulate ('acct_no', 'as_of_dt_day')
       ) AS dt
   ) WITH DATA;
```

Now that we’ve run through the examples, let's clean up the output tables from your personal database:

```sql
DROP TABLE "${UserName}".trans_feature_xgboost_model;

DROP TABLE "${UserName}".transaction_daily_counts;

DROP TABLE "${UserName}".acct_feature;

DROP TABLE "${UserName}".trans_feature_day_derived;

DROP TABLE "${UserName}".trans_feature_month_derived;

DROP TABLE "${UserName}".trans_feature;

DROP TABLE "${UserName}".acct_predict;
```

In just a few steps, we used Vantage to create and train a model and do prediction of first-party fraud on consumer banking data. Starting from (generated) raw customer, transactional and monthly data, we derived aggregate features to feed into the key analytic step: creating the model based on historical fraud data using XGBoost. Our model allowed us to predict potential fraudulent accounts.

#### Step 4: Visualizing results

The final step is to view the dashboard of the results!

Using a visualization tool, we can see a high-level map of the potential fraud across the countries in which the bank operates.

![](images/high_level_map.png)

The next tab shows another level of detail with a dot for each account. It is fully interactive and you can search for locations to drill down and look at the accounts. The size of the bubbles is the credit limit, which is the banks' potential risk. The color is showing if we have predicted fraud or not.

![](images/detail_map.png)

The last tab allows us to drill down at the customer (party) level and look at detailed activity and account summary information. Party Id: 426 is an example of normal behaviour. The customer spends money and pays it back on a cyclical monthly basis.

![](images/normal_behaviour.png)

Party Id: 547 is an example of a customer that has previously busted out. You can see a period of normal transaction behaviour followed by the maxing out of all lines of credit and then walking away without payback. You will also notice insufficient funds for returned payments and phone payments can characterize bust-out behaviour.

![](images/bust-out_behaviour.png)

Now lets take a look at what we can do to stop this. Bring up Party Id: 580, who has many accounts that have been flagged as potentially fraudulent by the XGBoost model. At first glance the activity looks normal, but there are signs that the model has detected such as insufficient funds and other behaviour that we need to investigate before the customer potentially maxes out their credit and disappears forever.

![](images/predicted_bust-out.png)

In just a few steps, we have used **Vantage** to create and train a model and do prediction of first-party fraud on consumer banking data. Starting from (generated) raw customer, transactional and monthly data, we derived aggregate features to feed into the key analytic step: creating the model based on historical fraud data using XGBoost. Our model allowed us to predict potential fraudulent accounts, which we were able to visualize, even drilling down to the individual customer level, with a visualization tool.

# Datasets

Three main data types are stored in the `[%_PREFIX_%]BustOutFraud` database: customer/merchant, transactional, and monthly.

#### Customer / Merchant Data

Three tables: `party`, `party_acct` and `merchant`

`party` is fake customer identity data from https://www.fakenamegenerator.com/. This demo was originally created for the EMEA Universe 2019 conference.

- `partyid`: party (customer) id - incrementing unique identifier
- `gender`: gender
- `nameset`: what set of names it is generated from (country/region)
- `firstname`: given name
- `lastname`: family name
- `streetaddress`: street address
- `city`: city
- `state`: state abbreviation
- `statefull`: state full name
- `postcode`: postal code
- `country`: country abbreviation (eg. PL)
- `countryfull`: country full name (eg. Poland)
- `email`: email address
- `username`: username
- `browseruseragent`: browser user agent
- `phone`: telephone number
- `telephonecountrycode`: telephone country code
- `mothersmaiden`: mother's maiden name
- `birthday`: birthday
- `age`: age
- `nationalid`: national ID number (for some countries)
- `occupation`: occupation
- `company`: company
- `guid`: global unique identifier
- `latitude`: latitude
- `longitude`: longitude

`party_acct` is the relationship between customers and the accounts they hold. The table contains:

- `partyid`: party (customer) id
- `acctno`: account number

`merchant` contains fake store identity data from https://www.fakenamegenerator.com/. The table contains 10,000 merchants and 6 'payment' merchants used to populate the transaction_detail table properly.

- `merchant_id`: merchant (business) id - incrementing unique identifier
- `merchant_name`: business name
- `streetaddress`: street address
- `city`: city
- `state`: state abbreviation
- `statefull`: state full name
- `postcode`: postal code
- `country`: country abbreviation (eg. PL)
- `countryfull`: country full name (eg. Poland)
- `phone`: telephone number
- `phone_country_code`: telephone country code
- `latitude`: latitude
- `longitude`: longitude

#### Transactional Data

We have detailed daily transaction data as a bank would hold.

`transaction_detail` is simulated data with every transaction (credits and debits) made against all the accounts we have at the bank. The customer behaviour modelled in here is one of the key things we are using to predict fraud. It contains 373,219 records covering 3 years of activity.

- `acct_no`: account number
- `tran_post_dt`: transaction date/time
- `tran_cat_cd`: type of transaction
- `trans_chnl`: transaction channel (purchase or payment type)
- `merchant_name`: merchant name or payment type
- `trans_amt`: transaction amount (+ is debit, - is credit)

#### Monthly Data

We also have monthly data related to the customers and accounts.

`acct_statement` is generated by the bank on a monthly basis and is a summary of the past month's activity and account status. There are 3 years of account data, but not all the accounts have been open that entire duration.

- `acct_no`: account number
- `as_of_dt_day`: statement date
- `credit_limit`: current credit limit
- `acq_chnl`: acquistion channel (how was the account opened)
- `acq_ecom_flag`: boolean - was the account opened online?
- `mth_on_book`: number of months on the books (since account opened)
- `eom_bal_amount`: end of the month balance

`credit_bureau_data` is simulated 3rd party data purchased by the bank on a monthly basis and gives additional summary of the past months credit activity that we may not otherwise have for our customers. Again, 3 years of data, but not all customers were with the bank that entire time.

- `acct_no`: account number
- `as_of_dt_day`: as of date
- `accts_clsd_by_grantor_ct`: number of accounts closed by grantor
- `accts_open_12m_ct`: accounts opened in past 12 months
- `avbl_cr_am`: available credit across all lines open
- `avg_bal_am`: average balance amount
- `accts_utlz_ge95_ct`: number of accts using >95% of the available credit line
- `credit_score`: current credit score
- `accts_30dlq_ct`: number of delinquent accounts in past 30 days
- `accts_60dlq_ct`: number of delinquent accounts in past 60 days
- `accts_90dlq_ct`: number of delinquent accounts in past 90 days
- `inq_bank_6m_ct`: number of credit inquires in the past 6 months (normally, validating or, most often, attempting to open new lines of credit)
- `msa_cd`: geographic region (metropolitan standardized area)
- `prev_credit_score`: previous credit score
- `accts_avg_age_mth_ct`: average age of accounts
- `accts_utlz_pct`: account utilisation percentage

# Explore

Feel free to take a closer look at the feature tables (note some features are not used in the demo yet), the model, and the visualization and see how Vantage can be used to effectively predict and prevent first party financial fraud using machine learning.
