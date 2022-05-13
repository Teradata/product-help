DROP TABLE retail_sample_data.ev_dtc ;

CREATE MULTISET FOREIGN TABLE retail_sample_data.ev_dtc , FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      fault_code VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      description VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC 
     )  
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/EVCarBattery/dtc.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;