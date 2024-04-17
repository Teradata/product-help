REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE ev_service_visits ;

CREATE MULTISET FOREIGN TABLE ev_service_visits , FALLBACK ,
     EXTERNAL SECURITY DefaultAuth,
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
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/EVCarBattery/service_visits.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
