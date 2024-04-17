REPLACE AUTHORIZATION DefaultAuth USER '' PASSWORD '';
DROP TABLE knee_replacement ;
CREATE MULTISET FOREIGN TABLE knee_replacement ,FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
     (
     memberid INTEGER,
     proccode INTEGER,
     diagcode VARCHAR(255),
     shortdesc VARCHAR(255),
     amount FLOAT,
     tstamp TIMESTAMP,
     firstname VARCHAR(255),
     lastname VARCHAR(255),
     email VARCHAR(255),
     state CHAR(2))
USING
(
     LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/KneeReplacement/knee_replacement/')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
