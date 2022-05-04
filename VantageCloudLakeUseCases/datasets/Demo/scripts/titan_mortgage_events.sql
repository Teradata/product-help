DROP TABLE retail_sample_data.demo_titan_mortgage_events ;
CREATE MULTISET FOREIGN TABLE retail_sample_data.demo_titan_mortgage_events ,FALLBACK ,
     EXTERNAL SECURITY DEFINER TRUSTED DEMO_AUTH_NOS ,
     MAP = TD_MAP1
( 
	entity_id 	VARCHAR(20),
	session_id	INTEGER,
	datestamp 	TIMESTAMP(6),
	event     	VARCHAR(100) 
	)
USING
(
	LOCATION  ('/s3/s3.amazonaws.com/alpha-data-store-td/retail_sample_data/Demo/titan_mortgage_events/')
	MANIFEST  ('FALSE')
	ROWFORMAT  ('{"field_delimiter":",","record_delimiter":"\n","character_set":"LATIN"}')
	STOREDAS  ('TEXTFILE')
	HEADER  ('FALSE')
	STRIP_EXTERIOR_SPACES  ('FALSE')
	STRIP_ENCLOSING_CHAR  ('NONE')
)
NO PRIMARY INDEX ;