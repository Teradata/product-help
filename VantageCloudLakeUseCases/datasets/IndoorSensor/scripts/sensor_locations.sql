REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE is_sensor_locations ;
CREATE MULTISET FOREIGN TABLE is_sensor_locations ,FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
     (
      id INTEGER NOT NULL,
      x FLOAT,
      y FLOAT)
USING
(
     LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/IndoorSensor/sensor_locations.csv')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
