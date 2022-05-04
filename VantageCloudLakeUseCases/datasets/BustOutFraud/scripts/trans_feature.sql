DROP TABLE retail_sample_data.bof_trans_feature ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.bof_trans_feature ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      acct_no VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
      as_of_dt_day DATE FORMAT 'YY/MM/DD',
      avg_pmt_05_mth DECIMAL(10,2),
      days_since_lstcash INTEGER,
      max_utilization_05_mth DECIMAL(12,5),
      maxamt_epmt_v7day DECIMAL(10,2),
      times_nsf INTEGER,
      totcash_to_line_v7day DECIMAL(12,5),
      totpmt_to_line_v7day DECIMAL(12,5),
      totpur_to_line_v7day DECIMAL(12,5),
      totpurcash_to_line_v7day DECIMAL(12,5),
      credit_util_cur_mth DECIMAL(12,5),
      credit_util_prior_5_mth DECIMAL(12,5),
      credit_util_cur_to_prior_ratio FLOAT,
      days_since_lst_pymnt INTEGER,
      num_pymnt_lst_7_days INTEGER,
      num_pymnt_lst_60_days INTEGER,
      pct_line_paid_lst_7_days DECIMAL(12,5),
      pct_line_paid_lst_30_days DECIMAL(12,5),
      num_pur_lst_7_days INTEGER,
      num_pur_lst_60_days INTEGER,
      pct_line_pur_lst_7_days DECIMAL(12,5),
      pct_line_pur_lst_30_days DECIMAL(12,5),
      tot_pymnt_chnl INTEGER,
      tot_pymnt INTEGER,
      tot_pymnt_am DECIMAL(10,2),
      pay_by_phone CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      elec_pymnt CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      pay_in_bank CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      pay_by_check CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      pay_by_othr CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      last_12m_trans_ct INTEGER)
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/BustOutFraud/trans_feature/')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;