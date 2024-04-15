REPLACE AUTHORIZATION DefaultAuth AS DEFINER TRUSTED USER '' PASSWORD '';
DROP TABLE ev_bom ;

CREATE MULTISET FOREIGN TABLE ev_bom , FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
     (
      id INTEGER NOT NULL,
      vin VARCHAR(17) CHARACTER SET LATIN NOT CASESPECIFIC,
      part_no VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      vendor_id INTEGER,
      lot_no VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      quantity INTEGER
     )  
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/EVCarBattery/bom.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
