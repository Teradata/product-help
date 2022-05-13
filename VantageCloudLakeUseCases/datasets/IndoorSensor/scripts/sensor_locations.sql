DROP TABLE retail_sample_data.is_sensor_locations ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.is_sensor_locations ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
     (
      id INTEGER NOT NULL,
      x FLOAT,
      y FLOAT)
USING
(
     LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/IndoorSensor/sensor_locations.csv')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;