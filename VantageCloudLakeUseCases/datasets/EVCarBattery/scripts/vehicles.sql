REPLACE AUTHORIZATION DefaultAuth AS DEFINER TRUSTED USER '' PASSWORD '';
DROP TABLE ev_vehicles ;

CREATE MULTISET FOREIGN TABLE ev_vehicles , FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
     (
      vin VARCHAR(17) CHARACTER SET UNICODE NOT NULL,
      yr INTEGER,
      model VARCHAR(255) CHARACTER SET UNICODE,
      customer_id INTEGER,
      dealer_id INTEGER,
      mfg_plant_id INTEGER
     )  
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/EVCarBattery/vehicles.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
