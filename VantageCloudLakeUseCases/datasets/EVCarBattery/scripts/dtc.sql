REPLACE AUTHORIZATION DefaultAuth AS DEFINER TRUSTED USER '' PASSWORD '';
DROP TABLE ev_dtc ;

CREATE MULTISET FOREIGN TABLE ev_dtc , FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
     (
      fault_code VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      description VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC 
     )  
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/EVCarBattery/dtc.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
