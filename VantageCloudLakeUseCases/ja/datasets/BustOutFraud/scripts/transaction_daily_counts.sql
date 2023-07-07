DROP TABLE bof_transaction_daily_counts ;
CREATE MULTISET FOREIGN TABLE bof_transaction_daily_counts ,FALLBACK ,
     EXTERNAL SECURITY retail_sample_data.DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      acct_no VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
      tran_post_dt DATE FORMAT 'YY/MM/DD',
      trans_type VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      payment_chnl VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      sum_amt DECIMAL(12,2),
      trans_cnt INTEGER)
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/BustOutFraud/transaction_daily_counts.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;