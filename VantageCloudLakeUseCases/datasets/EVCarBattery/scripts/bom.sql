DROP TABLE retail_sample_data.ev_bom ;

CREATE MULTISET FOREIGN TABLE retail_sample_data.ev_bom , FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
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
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/EVCarBattery/bom.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;