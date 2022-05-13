DROP TABLE retail_sample_data.ev_service_visits ;

CREATE MULTISET FOREIGN TABLE retail_sample_data.ev_service_visits , FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      id INTEGER NOT NULL, 
      vin VARCHAR(17) CHARACTER SET UNICODE,
      dealer_id INTEGER,
      service VARCHAR(255) CHARACTER SET UNICODE,
      cost INTEGER,
      warranty BYTEINT
     )  
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/EVCarBattery/service_visits.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;