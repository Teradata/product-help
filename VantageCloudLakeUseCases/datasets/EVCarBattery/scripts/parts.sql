REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE ev_parts ;

CREATE MULTISET FOREIGN TABLE ev_parts , FALLBACK ,
     EXTERNAL SECURITY DefaultAuth,
     MAP = TD_MAP1
     (
      part_no VARCHAR(20) CHARACTER SET UNICODE NOT NULL,
      description VARCHAR(255) CHARACTER SET UNICODE 
     )  
USING
(
      LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/EVCarBattery/parts.csv')
      MANIFEST  ('FALSE')
      ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
      STOREDAS  ('TEXTFILE')
      HEADER  ('FALSE')
      STRIP_EXTERIOR_SPACES  ('FALSE')
      STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
