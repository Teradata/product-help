DROP TABLE retail_sample_data.bof_acct_predict ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.bof_acct_predict ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      acct_no VARCHAR(19) CHARACTER SET UNICODE NOT CASESPECIFIC,
      as_of_dt_day DATE FORMAT 'YY/MM/DD',
      prediction VARCHAR(128) CHARACTER SET UNICODE NOT CASESPECIFIC,
      confidence_lower FLOAT,
      confidence_upper FLOAT)
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/BustOutFraud/acct_predict/')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;