DROP TABLE retail_sample_data.knee_replacement ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.knee_replacement ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
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
     LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/KneeReplacement/knee_replacement/')
     MANIFEST  ('FALSE')
     ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
     STOREDAS  ('TEXTFILE')
     HEADER  ('FALSE')
     STRIP_EXTERIOR_SPACES  ('FALSE')
     STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;