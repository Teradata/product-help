REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE bof_acct_statement ;
CREATE MULTISET FOREIGN TABLE bof_acct_statement ,FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
     (
      acct_no VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
      as_of_dt_day DATE FORMAT 'YY/MM/DD',
      credit_limit DECIMAL(18,2),
      acq_chnl CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
      acq_ecom_flag CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      mth_on_book INTEGER,
      eom_bal_amount DECIMAL(18,2))
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/BustOutFraud/acct_statement.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
