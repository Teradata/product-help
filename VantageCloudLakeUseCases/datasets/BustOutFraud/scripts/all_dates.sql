REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE bof_all_dates ;
CREATE MULTISET FOREIGN TABLE bof_all_dates ,FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
     (
      acct_no VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
      date_range DATE FORMAT 'YY/MM/DD',
      in_flag CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC)
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/BustOutFraud/all_dates/')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
