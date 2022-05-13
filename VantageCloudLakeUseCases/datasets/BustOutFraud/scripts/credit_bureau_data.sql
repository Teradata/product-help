DROP TABLE retail_sample_data.credit_bureau_data ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.credit_bureau_data ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      acct_no VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
      as_of_dt DATE FORMAT 'YY/MM/DD',
      accts_clsd_by_grantor_ct SMALLINT,
      accts_open_12m_ct SMALLINT,
      avbl_cr_am INTEGER,
      avg_bal_am INTEGER,
      accts_utlz_ge95_ct SMALLINT,
      credit_score SMALLINT,
      accts_30dlq_ct SMALLINT,
      accts_60dlq_ct SMALLINT,
      accts_90dlq_ct SMALLINT,
      inq_bank_6m_ct SMALLINT,
      msa_cd CHAR(5) CHARACTER SET LATIN NOT CASESPECIFIC,
      prev_credit_score SMALLINT,
      accts_avg_age_mth_ct SMALLINT,
      accts_utlz_pct INTEGER)
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/BustOutFraud/credit_bureau_data.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;