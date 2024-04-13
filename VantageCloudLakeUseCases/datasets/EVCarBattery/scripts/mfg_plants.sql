REPLACE AUTHORIZATION DefaultAuth AS DEFINER TRUSTED USER '' PASSWORD '';
DROP TABLE ev_mfg_plants ;

CREATE MULTISET FOREIGN TABLE ev_mfg_plants , FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
     (
      Id INTEGER NOT NULL,
      Company VARCHAR(100) CHARACTER SET UNICODE,
      StreetAddress VARCHAR(255) CHARACTER SET UNICODE,
      City VARCHAR(255) CHARACTER SET UNICODE,
      State VARCHAR(255) CHARACTER SET UNICODE,
      ZipCode INTEGER,
      Country VARCHAR(255) CHARACTER SET UNICODE,
      EmailAddress VARCHAR(255) CHARACTER SET UNICODE,
      TelephoneNumber VARCHAR(20) CHARACTER SET UNICODE,
      Latitude FLOAT,
      Longitude FLOAT 
     )  
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/EVCarBattery/mfg_plants.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
