REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE tc_csi_telco_data ;
CREATE MULTISET FOREIGN TABLE tc_csi_telco_data ,FALLBACK ,
    EXTERNAL SECURITY DefaultAuth ,
    MAP = TD_MAP1
    (
      customerid INTEGER NOT NULL,
      event VARCHAR(18) CHARACTER SET LATIN CASESPECIFIC,
      category VARCHAR(21) CHARACTER SET LATIN CASESPECIFIC,
      amount DECIMAL(5,2),
      duration BYTEINT,
      notes VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
      tstamp DATE FORMAT 'YY/MM/DD',
      timegroup VARCHAR(11) CHARACTER SET LATIN CASESPECIFIC)
USING
(
     LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/TelcoChurn/csi_telco_data/')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
