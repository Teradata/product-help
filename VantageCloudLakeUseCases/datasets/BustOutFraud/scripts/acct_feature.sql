DROP TABLE retail_sample_data.bof_acct_feature ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.bof_acct_feature ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      acct_no VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
      as_of_dt_day DATE FORMAT 'YY/MM/DD',
      accts_clsd_by_grantor_ct SMALLINT,
      accts_open_12m_ct SMALLINT,
      accts_utlz_ge95_ct SMALLINT,
      credit_score INTEGER,
      inq_bank_6m_ct SMALLINT,
      accts_avg_age_mth_ct SMALLINT,
      msa_flag CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      acq_chnl CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
      acq_ecom_flag CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      mth_on_book INTEGER,
      credit_limit DECIMAL(18,2),
      eom_bal_amount DECIMAL(18,2))
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/BustOutFraud/acct_feature.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;