REPLACE AUTHORIZATION DefaultAuth AS DEFINER TRUSTED USER '' PASSWORD '';
DROP TABLE demo_titan_mortgage_events ;
CREATE MULTISET FOREIGN TABLE demo_titan_mortgage_events ,FALLBACK ,
     EXTERNAL SECURITY DefaultAuth ,
     MAP = TD_MAP1
( 
	entity_id 	VARCHAR(20),
	session_id	INTEGER,
	datestamp 	TIMESTAMP(6),
	event     	VARCHAR(100) 
	)
USING
(
	LOCATION  ('/s3/s3.amazonaws.com/td-usecases-data-store/retail_sample_data/Demo/titan_mortgage_events/')
	MANIFEST  ('FALSE')
	ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
	STOREDAS  ('TEXTFILE')
	HEADER  ('FALSE')
	STRIP_EXTERIOR_SPACES  ('FALSE')
	STRIP_ENCLOSING_CHAR  ('"')
)
NO PRIMARY INDEX ;
