REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE so_sales_fact ;

CREATE MULTISET FOREIGN TABLE so_sales_fact ,FALLBACK ,
    EXTERNAL SECURITY DefaultAuth ,
    MAP = TD_MAP1
    (
    sales_date DATE FORMAT 'YY/MM/DD' NOT NULL,
    customer_id INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    basket_id BIGINT NOT NULL,
    product_id INTEGER NOT NULL,
    sales_quantity INTEGER NOT NULL,
    discount_amount FLOAT NOT NULL)
USING
(
     LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/SalesOffload/sales_fact/')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
