DROP TABLE retail_sample_data.bof_trans_feature_month_derived ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.bof_trans_feature_month_derived ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      acct_no VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
      as_of_dt_day DATE FORMAT 'YY/MM/DD',
      credit_limit DECIMAL(18,2),
      eom_bal_amount DECIMAL(18,2),
      CREDIT_UTIL_CUR_MONTH DECIMAL(12,5),
      CREDIT_UTIL_PRIOR_5_MTH DECIMAL(20,5),
      AVGLINE_UTIL_L6M DECIMAL(20,5),
      CREDIT_UTIL_CUR_TO_PRIOR_RATIO DECIMAL(20,5),
      MAX_UTILIZATION_05_MTH DECIMAL(20,5))
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/BustOutFraud/trans_feature_month_derived.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;