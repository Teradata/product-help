REPLACE AUTHORIZATION DefaultAuth AS DEFINER TRUSTED USER '' PASSWORD '';
DROP TABLE ev_badbatts ;

CREATE MULTISET FOREIGN TABLE ev_badbatts , FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
     (
         vin CHAR(17) CHARACTER SET LATIN NOT CASESPECIFIC
     )  
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/EVCarBattery/badbatts.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
