/*********************/
/* CHURN PATHS TABLE */
/* CHURN PATHS WITH 4 PRECEDING EVENTS */
DATABASE FSCustomerJourney;

CREATE TABLE ich_banking_churner_paths
AS
(
    SELECT * FROM nPath (
        ON (
            SELECT
                customer_identifier, interaction_timestamp, interaction_type as event, product_category,
                marketing_category, marketing_description, marketing_placement, sales_channel,
                conversion_sales, conversion_cost, conversion_margin
            FROM ich_banking
            WHERE
                product_category <> '-1'
        )
        PARTITION BY customer_identifier
        ORDER BY interaction_timestamp
        USING
        MODE (NONOVERLAPPING)
        -- Limit to a depth of 4 (plus closed)
        PATTERN ('(EVENT){4}.CLOSED')
        SYMBOLS (
            event <> 'ACCOUNT_CLOSED' AS EVENT,
            event =  'ACCOUNT_CLOSED' AS CLOSED
        )
        RESULT (
            ACCUMULATE( event OF ANY(EVENT) )  AS interaction_type_list,
            COUNT( event OF ANY(EVENT) )       AS click_depth,

            FIRST( customer_identifier of EVENT )  AS customer_identifier,
            FIRST( product_category OF EVENT )     AS product_category
        )
    )
)WITH DATA ;

/* QUERY FOR TABLEAU SANKEY CHURN PATHS VIZ*/
/*    SELECT TOP 100 CAST(path AS VARCHAR(1000))AS path,COUNT(*) AS cnt FROM nPath (
        ON (
            SELECT
                customer_identifier, interaction_timestamp, interaction_type as event, product_category,
                marketing_category, marketing_description, marketing_placement, sales_channel,
                conversion_sales, conversion_cost, conversion_margin
            FROM ich_banking
            WHERE
                product_category <> '-1'
        )
        PARTITION BY customer_identifier
        ORDER BY interaction_timestamp
        USING
        MODE (NONOVERLAPPING)
        -- Limit to a depth of 5 (plus closed)
        PATTERN ('(EVENT){5}.CLOSED')
        SYMBOLS (
            event <> 'ACCOUNT_CLOSED' AS EVENT,
            event =  'ACCOUNT_CLOSED' AS CLOSED
        )
        RESULT (
            ACCUMULATE( event OF ANY(EVENT, CLOSED) )  AS path
        )
    )
    group by path;
*/   

SELECT 
interaction_type_list as path, count(*) as cnt
from
ich_banking_churner_paths
group by path;

/* NONCHURN PATHS TABLE */
/* NON CHURN PATHS 5 EVENTS */
CREATE TABLE ich_banking_nonchurner_paths
AS
(
SELECT * FROM nPath (
        ON (
            SELECT
                customer_identifier, interaction_timestamp, interaction_type, product_category, interaction_type  AS event,
                marketing_category, marketing_description, marketing_placement, sales_channel,
                conversion_sales, conversion_cost, conversion_margin
            FROM ich_banking
            WHERE
                product_category <> '-1'
		-- Only real customers (that booked accounts)
                AND customer_identifier IN (SELECT DISTINCT customer_identifier FROM ich_banking where interaction_type LIKE 'ACCOUNT_BOOKED%')
		-- Don't use the people that churned
		AND customer_identifier NOT IN (SELECT distinct(customer_identifier) FROM  ich_banking_churner_paths)
		-- Also leave out the potential churners (these have later interactions)
		AND interaction_timestamp < (select max(interaction_timestamp) from ich_banking where interaction_type ='ACCOUNT_CLOSED')
        )
        PARTITION BY customer_identifier
        ORDER BY interaction_timestamp
        USING
        MODE (NONOVERLAPPING)
        -- Limit to a depth of 5
        PATTERN ('(EVENT){5}')
        SYMBOLS (
            event NOT LIKE 'ACCOUNT_CLOSED' AS EVENT
        )
        RESULT (
            ACCUMULATE( event OF ANY(EVENT) )  AS interaction_type_list,
            COUNT( event OF ANY(EVENT) )       AS click_depth,

            FIRST( customer_identifier of EVENT )  AS customer_identifier,
            FIRST( product_category OF EVENT )     AS product_category
        )
    )  
    )WITH DATA;
    
    
    
/* TOKENIZING NON CHURN PATHS */
CREATE MULTISET TABLE ich_banking_nonchurn_paths_token AS (
  SELECT * FROM NGramSplitter_MLE (
    ON  ich_banking_nonchurner_paths
    USING
    TextColumn ('interaction_type_list')
    Delimiter (',')
    Grams ('1')
    Overlapping ('false')
    ToLowerCase ('true')
    Punctuation ('\[.,?\!\]')
    Reset ('\[.,?\!\]')
    TotalGramCount ('false')
    Accumulate ('customer_identifier')
  ) AS dt
) WITH DATA;


/* TOKENIZING  CHURN PATHS */
CREATE MULTISET TABLE ich_banking_churn_paths_token AS (
  SELECT * FROM NGramSplitter_MLE (
    ON  ich_banking_churner_paths
    USING
    TextColumn ('interaction_type_list')
    Delimiter (',')
    Grams ('1')
    Overlapping ('false')
    ToLowerCase ('true')
    Punctuation ('\[.,?\!\]')
    Reset ('\[.,?\!\]')
    TotalGramCount ('false')
    Accumulate ('customer_identifier')
  ) AS dt
) WITH DATA;


/* CLEAN UP LEADING AND TRAILING CHARACTERS USING OREPLACE */
/* CLEANING TOKENIZED CHURN PATHS */
CREATE MULTISET TABLE ich_banking_churn_paths_token_clean AS (
SELECT 
oreplace 
(oreplace (ngram,'[',''), ']','')  as ngram , customer_identifier, n, frequency from ich_banking_churn_paths_token
) WITH DATA ;


/* CLEANING TOKENIZED NONCHURN PATHS */
CREATE MULTISET TABLE ich_banking_nonchurn_paths_token_clean AS (
SELECT 
oreplace 
(oreplace (ngram,'[',''), ']','')  as ngram , customer_identifier ,n, frequency from ich_banking_nonchurn_paths_token
) WITH DATA ;


/* RUNNING TF-IDF */

/* RUNNING TF-IDF ON NON CHURNERS */
CREATE MULTISET TABLE ich_banking_nonchurn_tfidf_input1 AS (
  SELECT customer_identifier as docid, ngram AS term, frequency AS "count"
  FROM ich_banking_nonchurn_paths_token_clean AS dt
) WITH DATA;

CREATE MULTISET TABLE ich_banking_nonchurn_tf1 AS (
  SELECT * FROM tf (
    ON ich_banking_nonchurn_tfidf_input1 PARTITION BY docid
  ) AS dt1
) WITH DATA;

CREATE MULTISET TABLE ich_banking_nonchurn_tfidf AS (
  SELECT * FROM TFIDF (
ON ich_banking_nonchurn_tf1 AS tf PARTITION BY term ON (
SELECT CAST(COUNT(DISTINCT(docid)) AS integer) AS "count" FROM ich_banking_nonchurn_tfidf_input1
) AS doccount DIMENSION
  ) AS dt
) WITH DATA;
  

 /* RUNNING TF-IDF ON CHURNERS */
CREATE MULTISET TABLE ich_banking_churn_tfidf_input1 AS (
  SELECT customer_identifier as docid, ngram AS term, frequency AS "count"
  FROM ich_banking_churn_paths_token_clean AS dt
) WITH DATA;

CREATE MULTISET TABLE ich_banking_churn_tf1 AS (
  SELECT * FROM tf (
    ON ich_banking_churn_tfidf_input1 PARTITION BY docid
  ) AS dt1
) WITH DATA;

CREATE MULTISET TABLE ich_banking_churn_tfidf AS (
  SELECT * FROM TFIDF (
ON ich_banking_churn_tf1 AS tf PARTITION BY term ON (
SELECT CAST(COUNT(DISTINCT(docid)) AS integer) AS "count" FROM ich_banking_churn_tfidf_input1
) AS doccount DIMENSION
  ) AS dt
) WITH DATA;
                                                                                                                                                                                                                                                
/* SLOPE CHART TABLE FOR TABLEAU : MERGING CHURN+NON-CHURN */
CREATE TABLE ich_banking_tfidf_slope
as (
select 
term, grp,
rank () over (partition by A.grp order by A.sum_tfidf desc) as sum_rank, sum_tfidf
from
(
select sum (tf_idf) sum_tfidf, term, 'CHURN' as grp
from ich_banking_churn_tfidf
group by 2,3
union ALL
select sum (tf_idf) sum_tfidf, term, 'NON CHURN' as grp
from ich_banking_nonchurn_tfidf
group by 2,3) as A)
with data ;


/* PREDICTION USING TEXT CLASSIFICATION */
 
/* 1- CHURN MODEL USING TEXT CLASSIFIER */

    
/* TOKENIZING NON CHURN PATHS FOR TRAINING SET*/
CREATE MULTISET TABLE ich_banking_nonchurn_paths_train_token AS (
  SELECT * FROM NGramSplitter_MLE (
    ON  (select top 2217 customer_identifier,interaction_type_list from ich_banking_nonchurner_paths)
    USING
    TextColumn ('interaction_type_list')
    Delimiter (',')
    Grams ('1')
    Overlapping ('false')
    ToLowerCase ('true')
    Punctuation ('\[.,?\!\]')
    Reset ('\[.,?\!\]')
    TotalGramCount ('false')
    Accumulate ('customer_identifier')
  ) AS dt
) WITH DATA;


/* CLEANING TOKENIZED NONCHURN PATHS FOR TRAINING SET  */
CREATE MULTISET TABLE ich_banking_nonchurn_paths_token_train_clean AS (
SELECT 
oreplace 
(oreplace (ngram,'[',''), ']','')  as ngram , customer_identifier ,n, frequency from ich_banking_nonchurn_paths_train_token
) WITH DATA ;


CREATE MULTISET TABLE ich_banking_churn_model 
AS (
SELECT * FROM NaiveBayesTextClassifierTrainer (
  ON (
SELECT * FROM NaiveBayesTextClassifierInternal (
ON (SELECT customer_identifier, lower(ngram) AS token, 'NON CHURN' as category FROM 
ich_banking_nonchurn_paths_token_train_clean
UNION ALL
SELECT customer_identifier, lower(ngram) AS token, 'CHURN' as category FROM 
ich_banking_churn_paths_token_clean
) AS "input" PARTITION BY category
USING
        TokenColumn ('token')
        ModelType ('Bernoulli')
        DocIDColumns ('customer_identifier')
        DocCategoryColumn ('category')
) AS alias_1
) PARTITION BY 1
) AS alias_2 
)
WITH DATA
;

-- select * from ich_banking_churn_model ;

-- Do some pathing for the unknown people
CREATE TABLE ich_banking_unknown_paths
AS(
    SELECT * FROM nPath (
        ON (
            SELECT
                customer_identifier, interaction_timestamp, interaction_type, product_category, interaction_type  AS event,
                marketing_category, marketing_description, marketing_placement, sales_channel,
                conversion_sales, conversion_cost, conversion_margin
            FROM ich_banking
            WHERE
                product_category <> '-1'
		-- Only real customers (that booked accounts)
                AND customer_identifier IN (SELECT DISTINCT customer_identifier FROM ich_banking where interaction_type LIKE 'ACCOUNT_BOOKED%')
		-- Exclude the training set people
                AND customer_identifier NOT IN (SELECT distinct(customer_identifier) FROM 
ich_banking_nonchurn_paths_token_train_clean
UNION ALL
SELECT distinct(customer_identifier)  FROM 
ich_banking_churn_paths_token_clean)
        )
        PARTITION BY customer_identifier
        ORDER BY interaction_timestamp
        USING
        MODE (NONOVERLAPPING)
        -- Only look for customers with a min depth of 5
        PATTERN ('(EVENT){5,}')
        SYMBOLS (
            event NOT LIKE 'ACCOUNT_CLOSED' AS EVENT
        )
        RESULT (
            ACCUMULATE( event OF ANY(EVENT) )  AS interaction_type_list,
            COUNT( event OF ANY(EVENT) )       AS click_depth,

            FIRST( customer_identifier of EVENT )  AS customer_identifier,
            FIRST( product_category OF EVENT )     AS product_category
        )
    ) )WITH DATA;
 

select count(distinct (customer_identifier)) from ich_banking_unknown_paths;
    
    
/* 2- PREDICTION ON UNKNOWN PATHS */


/* 2.2- TOKENIZING AND CLEANING UNKNOWN PATHS */
CREATE MULTISET TABLE ich_banking_unknown_token AS (
  SELECT * FROM NGramSplitter_MLE (
    ON  ich_banking_unknown_paths
    USING
    TextColumn ('interaction_type_list')
    Delimiter (',')
    Grams ('1')
    Overlapping ('false')
    ToLowerCase ('true')
    Punctuation ('\[.,?\!\]')
    Reset ('\[.,?\!\]')
    TotalGramCount ('false')
    Accumulate ('customer_identifier')
  ) AS dt
) WITH DATA;

select count(* ) from ich_banking_unknown_token;


CREATE MULTISET TABLE ich_banking_unknown_token_clean AS (
SELECT 
oreplace 
(oreplace (ngram,'[',''), ']','')  as ngram , customer_identifier ,n, frequency 
from ich_banking_unknown_token
) WITH DATA ;

/* 2.3- PREDICTION */
CREATE TABLE churn_predict
AS
(
SELECT * FROM NaiveBayesTextClassifierPredict_MLE (
  ON (
SELECT customer_identifier, lower(ngram) AS token  FROM 
ich_banking_unknown_token_clean
) AS predicts 
PARTITION BY customer_identifier
ON ich_banking_churn_model AS model DIMENSION USING
InputTokenColumn ('token')
ModelType ('Bernoulli')
DocIDColumns ('customer_identifier')
TopK (2)
) AS dt)
WITH DATA;


/* 2.4- PIVOT FUNCTION FOR TABLEAU VISUALIZATION */
CREATE TABLE churn_predict_pivot
as
(
SELECT * FROM Pivoting (
  ON churn_predict
  PARTITION BY customer_identifier ORDER BY customer_identifier, prediction
  USING
  PartitionColumns ('customer_identifier')
  NumberOfRows (2)
  TargetColumns ('loglik')
) AS dt ) 
with DATA;

select * from churn_predict_pivot_final;

CREATE TABLE churn_predict_pivot_final 
AS 
(
select A.customer_identifier as doc_id, prediction, loglik_0 as loglik_no_churn ,loglik_1 as loglik_churn
from (
select customer_identifier, prediction,loglik,
rank () over (partition by customer_identifier order by loglik desc) as rank1
from churn_predict 
group by customer_identifier, prediction, loglik) as A 
inner join churn_predict_pivot as B
on A.customer_identifier=B.customer_identifier
where rank1=1 )
with DATA;


CREATE TABLE churn_nb_input
AS 
(
SELECT customer_identifier, interaction_type_list FROM ich_banking_unknown_paths)WITH DATA;
DATABASE DBC;
