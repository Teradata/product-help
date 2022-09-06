DROP TABLE retail_sample_data.fscj_complaints ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.fscj_complaints ,FALLBACK ,
     EXTERNAL SECURITY retail_sample_data.DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
     id BIGINT,
     --customer_identifier VARCHAR(26),
     complaint VARCHAR(10000))
     --PRIMARY INDEX (customer_identifier)
USING
(
     LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/FSCustomerJourney/complaints.csv')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;